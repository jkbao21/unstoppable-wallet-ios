import LitecoinKit
import BitcoinCore
import RxSwift

class LitecoinAdapter: BitcoinBaseAdapter {
    private let litecoinKit: Kit

    init(wallet: Wallet, syncMode: SyncMode?, derivation: MnemonicDerivation?, testMode: Bool) throws {
        guard case let .mnemonic(words, _) = wallet.account.type, words.count == 12 else {
            throw AdapterError.unsupportedAccount
        }

        guard let walletDerivation = derivation else {
            throw AdapterError.wrongParameters
        }

        guard let walletSyncMode = syncMode else {
            throw AdapterError.wrongParameters
        }

        let networkType: Kit.NetworkType = testMode ? .testNet : .mainNet
        let bip = BitcoinBaseAdapter.bip(from: walletDerivation)
        let syncMode = BitcoinBaseAdapter.kitMode(from: walletSyncMode)
        let logger = App.shared.logger.scoped(with: "LitecoinKit")

        litecoinKit = try Kit(withWords: words, bip: bip, walletId: wallet.account.id, syncMode: syncMode, networkType: networkType, confirmationsThreshold: BitcoinBaseAdapter.confirmationsThreshold, logger: logger)

        super.init(abstractKit: litecoinKit)

        litecoinKit.delegate = self
    }

}

extension LitecoinAdapter: ISendBitcoinAdapter {
}

extension LitecoinAdapter {

    static func clear(except excludedWalletIds: [String]) throws {
        try Kit.clear(exceptFor: excludedWalletIds)
    }

}
