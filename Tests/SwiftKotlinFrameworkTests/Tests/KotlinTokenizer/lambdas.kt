userService.updateUser(picture = picture).always {  
    this.hasPhoto = true
}
userService.autoLinkTenant(tenantId = tenant.id).then { _  -> 
    this.startPayment(paymentMethod, true)
}.catchError { _  -> 
    val intent = this.coordinator.autoRegisterIntent(tenant = tenant, onComplete = { this.startPayment(paymentMethod, true) })
    this.navigationManager.show(intent, animation = .push)
}
item.selectCallback = { option  -> 
    presenter.selectPaymentMethod(option)
}
item.selectCallback?.invoke(option)
item.selectCallback!!.invoke(option)
ints.map {
    if (it == 0) {
        return@map "zero"
    }
    "non zero"
}
