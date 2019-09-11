var config = {
    testnet: false, // this is adjusted page.h if needed. dont need to change manually
    stagenet: false, // this is adjusted page.h if needed. dont need to change manually
    coinUnitPlaces: 9,
    txMinConfirms: 4, // corresponds to CRYPTONOTE_DEFAULT_TX_SPENDABLE_AGE in Monero
    txCoinbaseMinConfirms: 18, // corresponds to CRYPTONOTE_MINED_MONEY_UNLOCK_WINDOW in Monero
    coinSymbol: 'ARQ',
    openAliasPrefix: "arq",
    coinName: 'ArQmA',
    coinUriPrefix: 'arqma:',
    addressPrefix: 0x2cca,
    integratedAddressPrefix: 0x116bc7,
    subAddressPrefix: 0x6847,
    addressPrefixTestnet: 0x53ca,
    integratedAddressPrefixTestnet: 0x504a,
    subAddressPrefixTestnet: 0x524a,
    addressPrefixStagenet: 0x39ca,
    integratedAddressPrefixStagenet: 0x1742ca,
    subAddressPrefixStagenet: 0x1d84ca,
    feePerKB: new JSBigInt('20000'),//20^10 - for testnet its not used, as fee is dynamic.
    dustThreshold: new JSBigInt('10000'),//10^10 used for choosing outputs/change - we decompose all the way down if the receiver wants now regardless of threshold
    txChargeRatio: 0.5,
    defaultMixin: 11, // minimum mixin for hardfork v5
    txChargeAddress: '',
    idleTimeout: 30,
    idleWarningDuration: 20,
    maxBlockNumber: 500000000,
    avgBlockTime: 120,
    debugMode: false
};
