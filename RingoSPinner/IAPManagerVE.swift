import Foundation
internal import StoreKit
import Observation

@Observable
final class IAPManagerVE: NSObject {

    static let shared = IAPManagerVE()

    var products: [SKProduct] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var isRestoring: Bool = false
    var lastPurchasedProductId: String?
    var lastPurchaseError: Error?
    var lastAwardedCode: String?

    private static var observerAdded = false
    private var productsRequest: SKProductsRequest?

    private(set) var purchasedProductIds: Set<String> = []

    private let productIds: Set<String> = [
        "com.ringospinner.theme.neon",
        "com.ringospinner.theme.sunrise"
    ]

    private override init() {
        super.init()


        if !Self.observerAdded {
            SKPaymentQueue.default().add(self)
            Self.observerAdded = true
        }

        loadPurchased()
    }

    private func loadPurchased() {
        if let arr = UserDefaults.standard.array(forKey: "purchasedProductIdsVE") as? [String] {
            purchasedProductIds = Set(arr)
        } else {
            print("🟡 No saved purchases found")
        }
    }

    private func savePurchased() {
        UserDefaults.standard.set(Array(purchasedProductIds), forKey: "purchasedProductIdsVE")
    }

    func restorePurchases() {
        isLoading = true
        isRestoring = true

        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    func isPurchased(_ productId: String) -> Bool {
        purchasedProductIds.contains(productId)
    }

    func fetchProducts() {

        guard !isLoading else {
            return
        }

        isLoading = true

        productsRequest?.cancel()

        let req = SKProductsRequest(productIdentifiers: productIds)

        self.productsRequest = req
        req.delegate = self
        req.start()
    }

    func purchase(_ product: SKProduct) {
        guard SKPaymentQueue.canMakePayments() else {
            errorMessage = "Purchases are disabled on this device"
            lastPurchaseError = nil
            lastPurchasedProductId = nil
            return
        }

        isLoading = true

        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    private func handlePurchased(_ identifier: String) {

        self.isLoading = false
        self.purchasedProductIds.insert(identifier)
        self.savePurchased()
        self.errorMessage = nil
    }

    private func handleFailed(_ error: Error?) {

        DispatchQueue.main.async {

            if let skErr = error as? SKError,
               skErr.code == .paymentCancelled {

                self.isLoading = false
                return
            }

            self.lastPurchaseError = error
            self.errorMessage = error?.localizedDescription
            self.lastPurchasedProductId = nil
            self.isLoading = false
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue,
                      restoreCompletedTransactionsFailedWithError error: Error) {

        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            self.isRestoring = false
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {

        for t in queue.transactions {

            let id = t.payment.productIdentifier

            self.purchasedProductIds.insert(id)
        }

        savePurchased()

        DispatchQueue.main.async {

            if queue.transactions.isEmpty {
                self.errorMessage = "No purchases to restore"
            } else {
                self.errorMessage = "Purchases restored successfully!"
            }

            self.isRestoring = false
            self.isLoading = false
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue,
                      shouldAddStorePayment payment: SKPayment,
                      for product: SKProduct) -> Bool {
        return true
    }
}

extension IAPManagerVE: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest,
                         didReceive response: SKProductsResponse) {

        DispatchQueue.main.async {
            for product in response.products {

                print(
                    """
                    🟢 Product:
                    ID: \(product.productIdentifier)
                    Name: \(product.localizedTitle)
                    Price: \(product.price)
                    """
                )
            }

            if !response.invalidProductIdentifiers.isEmpty {

                print("🔴 Invalid product IDs:", response.invalidProductIdentifiers)
            }

            self.products = response.products.sorted {
                $0.price.doubleValue < $1.price.doubleValue
            }

            self.isLoading = false
            self.productsRequest = nil
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {

        print("🔴 Product request failed:", error.localizedDescription)

        DispatchQueue.main.async {

            self.errorMessage = error.localizedDescription
            self.isLoading = false
            self.productsRequest = nil
        }
    }
}

extension IAPManagerVE: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions txs: [SKPaymentTransaction]) {

        for tx in txs {

            print("🟡 Transaction state:", tx.transactionState.rawValue,
                  "Product:", tx.payment.productIdentifier)

            switch tx.transactionState {

            case .purchased:

                print("🟢 Transaction purchased:", tx.payment.productIdentifier)

                DispatchQueue.main.async {

                    let id = tx.payment.productIdentifier

                    self.purchasedProductIds.insert(id)
                    self.savePurchased()

                    self.lastPurchasedProductId = id
                    self.isLoading = false

                    SKPaymentQueue.default().finishTransaction(tx)
                }

            case .failed:

                print("🔴 Transaction failed")

                handleFailed(tx.error)

                SKPaymentQueue.default().finishTransaction(tx)

            case .restored:

                print("🟢 Transaction restored:", tx.payment.productIdentifier)

                DispatchQueue.main.async {

                    let id = tx.payment.productIdentifier

                    self.purchasedProductIds.insert(id)
                    self.savePurchased()

                    self.lastPurchasedProductId = id
                    self.isLoading = false

                    SKPaymentQueue.default().finishTransaction(tx)
                }

            case .deferred:

                print("🟡 Transaction deferred (waiting approval)")

                DispatchQueue.main.async {

                    self.isLoading = false
                    self.errorMessage = "Awaiting approval"
                }

            default:
                break
            }
        }
    }
}

extension SKProduct {

    var localizedPriceVE: String {

        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = self.priceLocale

        return f.string(from: self.price) ?? ""
    }

    var localizedNameVE: String {
        self.localizedTitle
    }
}
