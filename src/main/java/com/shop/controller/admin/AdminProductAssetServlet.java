package com.shop.controller.admin;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Iterator;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;

import com.shop.entity.Product;
import com.shop.entity.ProductImage;
import com.shop.entity.ProductSpecification;
import com.shop.entity.ProductVariant;
import com.shop.service.ProductImageService;
import com.shop.service.ProductService;
import com.shop.service.ProductSpecificationService;
import com.shop.service.ProductVariantService;
import com.shop.service.impl.ProductImageServiceImpl;
import com.shop.service.impl.ProductServiceImpl;
import com.shop.service.impl.ProductSpecificationServiceImpl;
import com.shop.service.impl.ProductVariantServiceImpl;
import com.shop.utils.WebUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(urlPatterns = {
        "/admin/products/variant/save", "/admin/products/image/save",
        "/admin/products/image/update", "/admin/products/image/delete", "/admin/products/spec/save",
        "/admin/products/spec/delete"
})
@MultipartConfig(fileSizeThreshold = 1024 * 1024, maxFileSize = 5L * 1024 * 1024,
        maxRequestSize = 6L * 1024 * 1024)
public class AdminProductAssetServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final long MAX_IMAGE_BYTES = 5L * 1024 * 1024;
    private static final int MAX_IMAGE_EDGE = 6000;
    private static final long MAX_IMAGE_PIXELS = 25_000_000L;
    private static final String UPLOAD_WEB_PATH = "/assets/uploads/products";
    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of("image/jpeg", "image/png");
    private final ProductService productService = new ProductServiceImpl();
    private final ProductVariantService variantService = new ProductVariantServiceImpl();
    private final ProductImageService imageService = new ProductImageServiceImpl();
    private final ProductSpecificationService specificationService =
            new ProductSpecificationServiceImpl();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long productId = null;
        try {
            productId = WebUtil.longParam(request, "productId");
            String path = request.getServletPath();
            if (path.endsWith("/variant/save")) saveVariant(request, productId);
            else if (path.endsWith("/image/save")) saveImage(request, productId);
            else if (path.endsWith("/image/update")) updateImage(request, productId);
            else if (path.endsWith("/image/delete")) deleteImage(request, productId);
            else if (path.endsWith("/spec/save")) saveSpecification(request, productId);
            else if (path.endsWith("/spec/delete")) deleteSpecification(request, productId);
            WebUtil.success(request, "Đã cập nhật dữ liệu sản phẩm.");
        } catch (IllegalArgumentException ex) {
            WebUtil.error(request, ex.getMessage());
        } catch (IllegalStateException ex) {
            WebUtil.error(request, "Ảnh tải lên không được vượt quá 5 MB.");
        } catch (ServletException | IOException ex) {
            getServletContext().log("Không thể xử lý ảnh sản phẩm", ex);
            WebUtil.error(request, "Không thể xử lý file ảnh đã tải lên.");
        }
        WebUtil.redirect(request, response, productId == null
                ? "/admin/products" : "/admin/products/form?id=" + productId);
    }

    private void saveVariant(HttpServletRequest request, Long productId) {
        Product product = requireProduct(productId);
        String idValue = request.getParameter("id");
        ProductVariant variant = idValue == null || idValue.isBlank()
                ? new ProductVariant() : variantService.findById(Long.valueOf(idValue));
        if (variant == null) throw new IllegalArgumentException("Không tìm thấy phiên bản.");
        if (variant.getVariantId() != null
                && !variant.getProduct().getProductId().equals(productId)) {
            throw new IllegalArgumentException("Phiên bản không thuộc sản phẩm này.");
        }
        variant.setProduct(product);
        variant.setSku(required(request, "sku"));
        variant.setVariantName(required(request, "variantName"));
        variant.setColor(WebUtil.trimToNull(request.getParameter("color")));
        variant.setRam(WebUtil.trimToNull(request.getParameter("ram")));
        variant.setStorage(WebUtil.trimToNull(request.getParameter("storage")));
        variant.setPrice(new BigDecimal(required(request, "price")));
        String original = request.getParameter("originalPrice");
        variant.setOriginalPrice(original == null || original.isBlank() ? null : new BigDecimal(original));
        variant.setStockQuantity(Integer.parseInt(required(request, "stockQuantity")));
        variant.setActive(request.getParameter("active") != null);
        if (variant.getVariantId() == null) variantService.create(variant); else variantService.update(variant);
    }

    private void saveImage(HttpServletRequest request, Long productId)
            throws IOException, ServletException {
        ProductImage image = new ProductImage();
        Product product = requireProduct(productId);
        image.setProduct(product);
        String variantId = request.getParameter("variantId");
        ProductVariant variant = variantId == null || variantId.isBlank()
                ? null : variantService.findById(Long.valueOf(variantId));
        if (variantId != null && !variantId.isBlank() && variant == null) {
            throw new IllegalArgumentException("Không tìm thấy phiên bản sản phẩm.");
        }
        if (variant != null && !variant.getProduct().getProductId().equals(productId)) {
            throw new IllegalArgumentException("Phiên bản ảnh không thuộc sản phẩm đã chọn.");
        }
        image.setVariant(variant);

        String providedUrl = WebUtil.trimToNull(request.getParameter("imageUrl"));
        Part imageFile = request.getPart("imageFile");
        boolean hasUpload = imageFile != null && imageFile.getSize() > 0;
        if (providedUrl != null && hasUpload) {
            throw new IllegalArgumentException("Chỉ chọn một trong hai: URL hoặc file ảnh.");
        }
        Path storedFile = null;
        if (hasUpload) {
            StoredImage storedImage = storeUploadedImage(imageFile);
            image.setImageUrl(storedImage.webPath());
            storedFile = storedImage.filePath();
        } else if (providedUrl != null) {
            image.setImageUrl(providedUrl);
        } else {
            throw new IllegalArgumentException("Hãy nhập URL hoặc chọn file ảnh JPEG/PNG.");
        }
        image.setPrimary(request.getParameter("primary") != null);
        String sortOrder = request.getParameter("sortOrder");
        image.setSortOrder(sortOrder == null || sortOrder.isBlank() ? 0 : Integer.parseInt(sortOrder));
        try {
            imageService.create(image);
        } catch (RuntimeException ex) {
            if (storedFile != null) Files.deleteIfExists(storedFile);
            throw ex;
        }
    }

    private void deleteImage(HttpServletRequest request, Long productId) throws IOException {
        Long imageId = WebUtil.longParam(request, "id");
        ProductImage image = imageService.findById(imageId);
        if (image == null || !image.getProduct().getProductId().equals(productId)) {
            throw new IllegalArgumentException("Không tìm thấy hình ảnh của sản phẩm.");
        }
        if (!imageService.delete(imageId)) {
            throw new IllegalArgumentException("Không thể xóa hình ảnh sản phẩm.");
        }
        deleteLocalUpload(image.getImageUrl());
    }

    private void updateImage(HttpServletRequest request, Long productId) {
        int sortOrder;
        try {
            sortOrder = Integer.parseInt(required(request, "sortOrder"));
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Thứ tự hình ảnh phải là số nguyên.");
        }
        imageService.updateMetadata(productId, WebUtil.longParam(request, "id"),
                sortOrder, request.getParameter("primary") != null);
    }

    private StoredImage storeUploadedImage(Part part) throws IOException {
        if (part.getSize() <= 0 || part.getSize() > MAX_IMAGE_BYTES) {
            throw new IllegalArgumentException("Ảnh tải lên phải có dung lượng từ 1 byte đến 5 MB.");
        }
        String submittedName = part.getSubmittedFileName();
        if (submittedName == null || submittedName.isBlank() || submittedName.length() > 255
                || submittedName.chars().anyMatch(Character::isISOControl)) {
            throw new IllegalArgumentException("Tên file ảnh không hợp lệ.");
        }
        String contentType = part.getContentType() == null
                ? "" : part.getContentType().toLowerCase(Locale.ROOT);
        if (!ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw new IllegalArgumentException("Chỉ chấp nhận ảnh JPEG hoặc PNG.");
        }

        String format = inspectImage(part);
        String extension = "jpeg".equals(format) || "jpg".equals(format) ? ".jpg" : ".png";
        String realUploadPath = getServletContext().getRealPath(UPLOAD_WEB_PATH);
        if (realUploadPath == null) {
            throw new IOException("Không xác định được thư mục lưu ảnh của ứng dụng.");
        }
        Path uploadDirectory = Path.of(realUploadPath).toAbsolutePath().normalize();
        Files.createDirectories(uploadDirectory);
        String generatedName = UUID.randomUUID().toString().replace("-", "") + extension;
        Path target = uploadDirectory.resolve(generatedName).normalize();
        if (!target.startsWith(uploadDirectory)) {
            throw new IllegalArgumentException("Đường dẫn lưu ảnh không hợp lệ.");
        }
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, target);
        }
        return new StoredImage("assets/uploads/products/" + generatedName, target);
    }

    private String inspectImage(Part part) throws IOException {
        try (InputStream input = part.getInputStream();
                ImageInputStream imageInput = ImageIO.createImageInputStream(input)) {
            if (imageInput == null) throw new IllegalArgumentException("File tải lên không phải ảnh hợp lệ.");
            Iterator<ImageReader> readers = ImageIO.getImageReaders(imageInput);
            if (!readers.hasNext()) throw new IllegalArgumentException("Không đọc được nội dung file ảnh.");
            ImageReader reader = readers.next();
            try {
                reader.setInput(imageInput, true, true);
                String format = reader.getFormatName().toLowerCase(Locale.ROOT);
                if (!("jpeg".equals(format) || "jpg".equals(format) || "png".equals(format))) {
                    throw new IllegalArgumentException("Nội dung file không phải ảnh JPEG hoặc PNG.");
                }
                int width = reader.getWidth(0);
                int height = reader.getHeight(0);
                if (width <= 0 || height <= 0 || width > MAX_IMAGE_EDGE || height > MAX_IMAGE_EDGE
                        || (long) width * height > MAX_IMAGE_PIXELS) {
                    throw new IllegalArgumentException(
                            "Kích thước ảnh tối đa 6000x6000 và không quá 25 triệu pixel.");
                }
                return format;
            } finally {
                reader.dispose();
            }
        }
    }

    private void deleteLocalUpload(String imageUrl) throws IOException {
        String prefix = "assets/uploads/products/";
        if (imageUrl == null || !imageUrl.startsWith(prefix)) return;
        String fileName = imageUrl.substring(prefix.length());
        if (!fileName.matches("[a-f0-9]{32}\\.(jpg|png)")) return;
        String realUploadPath = getServletContext().getRealPath(UPLOAD_WEB_PATH);
        if (realUploadPath == null) return;
        Path uploadDirectory = Path.of(realUploadPath).toAbsolutePath().normalize();
        Path target = uploadDirectory.resolve(fileName).normalize();
        if (target.startsWith(uploadDirectory)) Files.deleteIfExists(target);
    }

    private void saveSpecification(HttpServletRequest request, Long productId) {
        String idValue = request.getParameter("id");
        ProductSpecification specification = idValue == null || idValue.isBlank()
                ? new ProductSpecification()
                : specificationService.findById(Long.valueOf(idValue));
        if (specification == null) throw new IllegalArgumentException("Không tìm thấy thông số.");
        if (specification.getSpecificationId() != null
                && !specification.getProduct().getProductId().equals(productId)) {
            throw new IllegalArgumentException("Thông số không thuộc sản phẩm này.");
        }
        specification.setProduct(requireProduct(productId));
        specification.setSpecificationName(required(request, "specificationName"));
        specification.setSpecificationValue(required(request, "specificationValue"));
        String sortOrder = request.getParameter("sortOrder");
        specification.setSortOrder(sortOrder == null || sortOrder.isBlank() ? 0 : Integer.parseInt(sortOrder));
        if (specification.getSpecificationId() == null) specificationService.create(specification);
        else specificationService.update(specification);
    }

    private void deleteSpecification(HttpServletRequest request, Long productId) {
        Long id = WebUtil.longParam(request, "id");
        ProductSpecification specification = specificationService.findById(id);
        if (specification == null || !specification.getProduct().getProductId().equals(productId)) {
            throw new IllegalArgumentException("Không tìm thấy thông số của sản phẩm.");
        }
        specificationService.delete(id);
    }

    private Product requireProduct(Long id) {
        Product product = productService.findById(id);
        if (product == null) throw new IllegalArgumentException("Không tìm thấy sản phẩm.");
        return product;
    }

    private String required(HttpServletRequest request, String name) {
        String value = WebUtil.trimToNull(request.getParameter(name));
        if (value == null) throw new IllegalArgumentException(name + " không được để trống.");
        return value;
    }

    private record StoredImage(String webPath, Path filePath) {}
}
