enum WalletProvider { metamask, solfare, phantom, trust }

enum SupportedNetworks {
  ethereum,
  solana,
  polygon;

  /// Uppercase network identifier required by backend APIs (e.g. "SOLANA", "ETHEREUM", "POLYGON").
  String get apiValue => name.toUpperCase();

  /// Human-readable display name.
  String get displayName => switch (this) {
    SupportedNetworks.ethereum => 'Ethereum',
    SupportedNetworks.solana => 'Solana',
    SupportedNetworks.polygon => 'Polygon',
  };
}
