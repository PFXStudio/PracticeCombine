//
//  Service.swift
//  PracticeCombine
//
//  Created by nyon on 2022/03/30.
//

import Foundation
import Combine

protocol Serviceable {
    func fetchCompanies() -> Future<[String], Error>
}

enum ErrorMessage: LocalizedError {
    case wrongRequest
    var errorDescription: String? {
        switch self {
        case .wrongRequest:
            return NSLocalizedString("잘못된 요청입니다.", comment: "")
        }
    }
}

struct Service: Serviceable {
    func fetchCompanies() -> Future<[String], Error> {
        return Future { promixe in
            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
                promixe(.success(["네이버", "카카오", "라인", "쿠팡", "배민", "당근마켓", "토스",
                                  "네이버", "카카오", "라인", "쿠팡", "배민", "당근마켓", "토스",
                                  "네이버", "카카오", "라인", "쿠팡", "배민", "당근마켓", "토스",
                                 ]))
            }
//            DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
//                promixe(.failure(ErrorMessage.wrongRequest))
//            }
        }
    }
}
