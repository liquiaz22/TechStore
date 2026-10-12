package com.shop.service;

import java.time.LocalDate;

import com.shop.dto.AdminReportDTO.Dashboard;

public interface AdminReportService {
    Dashboard getDashboard(LocalDate fromDate, LocalDate toDate);
}
