

userService.updateUser(picture: picture).always { [weak self] in
    self?.hasPhoto = true
}

userService.autoLinkTenant(tenantId: tenant.id).then { [weak self] _ in
    self?.startPayment(paymentMethod, true)
}.catchError { [weak self] _ in
    let intent = self?.coordinator.autoRegisterIntent(tenant: tenant, onComplete: {
        self?.startPayment(paymentMethod, true)
    })
    self?.navigationManager.show(intent, animation: .push)
}

item.selectCallback = { option in
    presenter.selectPaymentMethod(option)
}

item.selectCallback?(option)
item.selectCallback!(option)

ints.map {
    if $0 == 0 {
        return "zero"
    }
    return "non zero"
}
