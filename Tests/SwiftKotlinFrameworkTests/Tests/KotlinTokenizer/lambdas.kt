userService.updateUser(picture = picture).always {  
    this?.hasPhoto = true
}
userService.autoLinkTenant(tenantId = tenant.id).then { _  -> 
    this?.startPayment(paymentMethod, true)
}.catchError { _  -> 
    val intent = this?.coordinator?.autoRegisterIntent(tenant = tenant, onComplete = { this?.startPayment(paymentMethod, true) })
    this?.navigationManager?.show(intent, animation = .push)
}
item.selectCallback = { option  -> 
    presenter.selectPaymentMethod(option)
}
