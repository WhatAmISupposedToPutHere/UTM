//
// Copyright © 2022 osy. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// Settings for a single display.
@available(iOS 13, macOS 11, *)
class UTMQemuConfigurationDisplay: Codable, Identifiable, ObservableObject {
    /// Hardware card to emulate.
    @Published var hardware: QEMUDisplayDevice = QEMUDisplayDevice_x86_64.virtio_vga
    
    /// If true, attempt to use SPICE guest agent to change the display resolution automatically.
    @Published var isDynamicResolution: Bool = true
    
    /// Filter to use when upscaling.
    @Published var upscalingFilter: QEMUScaler = .nearest
    
    /// Filter to use when downscaling.
    @Published var downscalingFilter: QEMUScaler = .linear
    
    /// If true, use the true (retina) resolution of the display. Otherwise, use the percieved resolution.
    @Published var isNativeResolution: Bool = false
    
    let id = UUID()
    
    enum CodingKeys: String, CodingKey {
        case hardware = "Hardware"
        case isDynamicResolution = "DynamicResolution"
        case upscalingFilter = "UpscalingFilter"
        case downscalingFilter = "DownscalingFilter"
        case isNativeResolution = "NativeResolution"
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hardware = try values.decode(AnyQEMUConstant.self, forKey: .hardware)
        isDynamicResolution = try values.decode(Bool.self, forKey: .isDynamicResolution)
        upscalingFilter = try values.decode(QEMUScaler.self, forKey: .upscalingFilter)
        downscalingFilter = try values.decode(QEMUScaler.self, forKey: .downscalingFilter)
        isNativeResolution = try values.decode(Bool.self, forKey: .isNativeResolution)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hardware.asAnyQEMUConstant(), forKey: .hardware)
        try container.encode(isDynamicResolution, forKey: .isDynamicResolution)
        try container.encode(upscalingFilter, forKey: .upscalingFilter)
        try container.encode(downscalingFilter, forKey: .downscalingFilter)
        try container.encode(isNativeResolution, forKey: .isNativeResolution)
    }
}

// MARK: - Default construction

@available(iOS 13, macOS 11, *)
extension UTMQemuConfigurationDisplay {
    convenience init?(forArchitecture architecture: QEMUArchitecture, target: QEMUTarget) {
        self.init()
        let rawTarget = target.rawValue
        if rawTarget.hasPrefix("pc") || rawTarget.hasPrefix("q35") {
            hardware = QEMUDisplayDevice_x86_64.virtio_vga
        } else if rawTarget.hasPrefix("virt-") || rawTarget == "virt" {
            hardware = QEMUDisplayDevice_aarch64.virtio_ramfb
        } else {
            return nil
        }
    }
}
