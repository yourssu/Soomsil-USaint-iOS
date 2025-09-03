//
//  MixpanelClient.swift
//  Soomsil-USaint
//
//  Created by 성현주 on 9/4/25.
//

import Mixpanel
import Dependencies

struct MixpanelClient {
    func track(_ event: String, properties: Properties = [:]) {
#if DEBUG
        print("📊 [Mixpanel Track] \(event)")
        if !properties.isEmpty {
            print("Properties: \(properties)")
        }
#endif
        Mixpanel.mainInstance().track(event: event, properties: properties)
    }

    func identify(userId: String) {
#if DEBUG
        print("[Mixpanel Identify] userId: \(userId)")
#endif
        Mixpanel.mainInstance().identify(distinctId: userId)
    }

    func reset() {
#if DEBUG
        print("🔄 [Mixpanel Reset]")
#endif
        Mixpanel.mainInstance().reset()
    }
}

extension MixpanelClient: DependencyKey {
    static let liveValue = MixpanelClient()
}

extension DependencyValues {
    var mixpanelClient: MixpanelClient {
        get { self[MixpanelClient.self] }
        set { self[MixpanelClient.self] = newValue }
    }
}
