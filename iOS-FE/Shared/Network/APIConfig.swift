enum APIConfig {
    static let baseDomain = "http://34.120.215.23"
    
    enum Order {
        static let baseURL = "\(baseDomain)/order/api/v1"
    }

    enum Receipt {
        static let baseURL = "\(baseDomain)/receipt/api/v1"
    }

    enum Inventory {
        static let baseURL = "\(baseDomain)/inventory/api/v1"
    }
}
