enum APIConfig {
    enum Domain {
        static let api = "http://34.120.215.23"
    }

    enum Auth {
        static let baseURL = "\(Domain.api)/auth"
    }

    enum User {
        static let baseURL = "\(Domain.api)/user/api/v1"
    }
    
    enum Order {
        static let baseURL = "\(Domain.api)/order/api/v1"
    }

    enum Receipt {
        static let baseURL = "\(Domain.api)/receipt/api/v1"
    }

    enum Inventory {
        static let baseURL = "\(Domain.api)/inventory/api/v1"
    }
    
    enum Warehouse {
        static let baseURL = "\(Domain.api)/warehouse/api/v1"
    }
}
