//
//  RSEventsAndKeys.swift
//  RudderStack
//
//  Created by Pallab Maiti on 15/11/21.
//  Copyright © 2021 Rudder Labs India Pvt Ltd. All rights reserved.
//

import Foundation

public struct RSEvents {
    public struct Ecommerce {
        public static let productsSearched = "Products Searched"
        public static let productListViewed = "Product List Viewed"
        public static let productListFiltered = "Product List Filtered"
        public static let promotionViewed = "Promotion Viewed"
        public static let promotionClicked = "Promotion Clicked"
        public static let productClicked = "Product Clicked"
        public static let productViewed = "Product Viewed"
        public static let productAdded = "Product Added"
        public static let productRemoved = "Product Removed"
        public static let cartViewed = "Cart Viewed"
        public static let checkoutStarted = "Checkout Started"
        public static let checkoutStepViewed = "Checkout Step Viewed"
        public static let checkoutStepCompleted = "Checkout Step Completed"
        public static let paymentInfoEntered = "Payment Info Entered"
        public static let orderUpdated = "Order Updated"
        public static let orderCompleted = "Order Completed"
        public static let orderRefunded = "Order Refunded"
        public static let orderCancelled = "Order Cancelled"
        public static let couponEntered = "Coupon Entered"
        public static let couponApplied = "Coupon Applied"
        public static let couponDenied = "Coupon Denied"
        public static let couponRemoved = "Coupon Removed"
        public static let productAddedToWishList = "Product Added to Wishlist"
        public static let productRemovedFromWishList = "Product Removed from Wishlist"
        public static let wishListProductAddedToCart = "Wishlist Product Added to Cart"
        public static let productShared = "Product Shared"
        public static let cartShared = "Cart Shared"
        public static let productReviewed = "Product Reviewed"
        public static let spendCredits = "Spend Credits"
        public static let reserve = "Reserve"
    }
    
    public struct LifeCycle {
        public static let applicationInstalled = "Application Installed"
        public static let applicationUpdated = "Application Updated"
        public static let applicationOpened = "Application Opened"
        public static let applicationBackgrounded = "Application Backgrounded"
        public static let completeRegistration = "Complete Registration"
        public static let completeTutorial = "Complete Tutorial"
        public static let achieveLevel = "Achieve Level"
        public static let unlockAchievement = "Unlock Achievement"
    }
}

public struct RSKeys {
    public struct Ecommerce {
        public static let price = "price"
        public static let productId = "product_id"
        public static let category = "category"
        public static let currency = "currency"
        public static let listId = "list_id"
        public static let products = "products"
        public static let wishlistId = "wishlist_id"
        public static let wishlistName = "wishlist_name"
        public static let quantity = "quantity"
        public static let cartId = "cart_id"
        public static let checkoutId = "checkout_id"
        public static let total = "total"
        public static let revenue = "revenue"
        public static let orderId = "order_id"
        public static let coupon = "coupon"
        public static let couponId = "coupon_id"
        public static let couponName = "coupon_name"
        public static let discount = "discount"
        public static let reviewId = "review_id"
        public static let reviewBody = "review_body"
        public static let rating = "rating"
        public static let sku = "sku"
        public static let brand = "brand"
        public static let variant = "variant"
        public static let productName = "name"
        public static let value = "value"
        public static let shipping = "shipping"
        public static let affiliation = "affiliation"
        public static let tax = "tax"
        public static let query = "query"
        public static let url = "url"
        public static let imageUrl = "image_url"
        public static let paymentMethod = "payment_method"
        public static let promotionId = "promotion_id"
        public static let creative = "creative"
    }
    
    public struct Identify {
        public static let userId = "user_id"
        public static let currencyCode = "currency_code"
        
        public struct Traits { // swiftlint:disable:this nesting
            public static let id = "id"
            public static let firstName = "firstName"
            public static let lastName = "lastName"
            public static let name = "name"
            public static let age = "age"
            public static let email = "email"
            public static let phone = "phone"
            public static let address = "address"
            public static let birthday = "birthday"
            public static let company = "company"
            public static let createdAt = "createdAt"
            public static let description = "description"
            public static let gender = "gender"
            public static let title = "title"
            public static let username = "username"
            public static let website = "website"
            public static let avatar = "avatar"
        }
    }
    
    public struct Screen {
        public static let screenViewed = "Screen Viewed"
    }
    
    public struct Other {
        public static let sorts = "sorts"
        public static let filters = "filters"
        public static let reason = "reason"
        public static let shareVia = "share_via"
        public static let shareMessage = "share_message"
        public static let recipient = "recipient"
        public static let interest = "interest"
        public static let itemName = "item_name"
    }
}
