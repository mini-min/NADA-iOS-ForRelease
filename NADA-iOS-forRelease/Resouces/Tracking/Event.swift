//
//  Event.swift
//  NADA-iOS-forRelease
//
//  Created by kimhyungyu on 2023/05/18.
//

import Foundation

extension Tracking {
    struct Event {
        private init() { }
        static let touchOnboardingStart = "A2 온보딩_시작"
        static let touchKakaoLogin = "A3 로그인_카카오"
        static let touchAppleLogin = "A3 로그인_애플"
        static let touchDarkmode = "E1 설정_다크모드"
        static let touchPrivacyPolicy = "E1 설정_개인정보"
        static let touchTermsOfUse = "E1 설정_이용약관"
        static let touchTeamNADA = "E1 설정_팀나다"
        static let touchOpenSource = "E1 설정_오픈소스"
        static let touchLogout = "E1 설정_로그아웃"
        static let touchReset = "E1 설정_초기화"
        static let touchDelete = "E1 설정_탈퇴"
    }
}
