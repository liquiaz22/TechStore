package com.shop.dto;

import lombok.Getter;

@Getter
public class VNPayResult {
    private final String responseCode;
    private final String responseMessage;
    private final boolean transactionSuccessful;
    private final String orderCode;
    private final String displayMessage;

    public VNPayResult(String responseCode, String responseMessage,
            boolean transactionSuccessful, String orderCode, String displayMessage) {
        this.responseCode = responseCode;
        this.responseMessage = responseMessage;
        this.transactionSuccessful = transactionSuccessful;
        this.orderCode = orderCode;
        this.displayMessage = displayMessage;
    }
}
