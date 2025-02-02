//
//  TagService.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2023/09/26.
//

import Foundation

import Moya

enum TagService {
    case tagCreation(request: CreationTagRequest)
    case tagFetch
    case receivedTagFetch(cardUUID: String)
    case tagDelete(request: [TagDeletionRequest])
    case tagFiltering(query: String)
}

extension TagService: TargetType {
    var baseURL: URL {
        return URL(string: Const.URL.baseURL)!
    }
    
    var path: String {
        switch self {
        case .tagCreation:
            return "/v1/card/tag"
        case .tagFetch:
            return "/v1/tag/image"
        case .receivedTagFetch(let cardUUID):
            return "/v1/card/tag/card/\(cardUUID)"
        case .tagDelete:
            return "/v1/card/tag/delete"
        case .tagFiltering:
            return "/v1/slang"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .tagCreation, .tagDelete:
            return .post
        case .tagFetch, .receivedTagFetch, .tagFiltering:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .tagCreation(let request):
            return .requestJSONEncodable(request)
        case .tagDelete(let request):
            return .requestJSONEncodable(request)
        case .tagFiltering(let query):
            return .requestParameters(parameters: ["text": query], encoding: URLEncoding.queryString)
        case .tagFetch, .receivedTagFetch:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .tagCreation, .tagDelete:
            return Const.Header.basicHeader()
        case .tagFetch, .receivedTagFetch, .tagFiltering:
            return Const.Header.bearerHeader()
        }
    }
}
