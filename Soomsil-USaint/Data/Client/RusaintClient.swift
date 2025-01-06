//
//  RusaintClient.swift
//  Soomsil-USaint
//
//  Created by 이조은 on 1/6/25.
//

/**
 Rusaint에서 반환하는 오류

 현재 오류에 대한 세부정보를 연관 값으로 받지 않고 에러 타입만 정의해둔 상태
 */
public enum RusaintError: Error {
    case webDynproError
    case invalidClientError
    case ssoLoginError
    case applicationError
}