import Foundation
import Cocoa

// MARK: - MultiTouch private API bridging

typealias MTDeviceRef = UnsafeMutableRawPointer

typealias MTContactCallback = @convention(c) (
    MTDeviceRef?,
    UnsafeMutablePointer<MTContact>?,
    Int32,
    Double,
    Int32,
    UnsafeMutableRawPointer?
) -> Void

struct MTPoint {
    var x: Float
    var y: Float
}

struct MTContact {
    var frame: Int32
    var timestamp: Double
    var identifier: Int32
    var state: Int32
    var normalized: MTPoint
    var size: Float
    var angle: Float
    var majorAxis: Float
    var minorAxis: Float
}

@_silgen_name("MTDeviceCreateList")
func MTDeviceCreateList() -> Unmanaged<CFArray>?

@_silgen_name("MTRegisterContactFrameCallback")
func MTRegisterContactFrameCallback(_ device: MTDeviceRef, _ callback: MTContactCallback?, _ userInfo: UnsafeMutableRawPointer?)

@_silgen_name("MTDeviceStart")
func MTDeviceStart(_ device: MTDeviceRef, _ unknown: Int32)

@_silgen_name("MTDeviceStop")
func MTDeviceStop(_ device: MTDeviceRef)

class MultiTouchMonitor {
    private var devices: [MTDeviceRef] = []
    private var callback: () -> Void

    init(action: @escaping () -> Void) {
        self.callback = action
        start()
    }

    deinit {
        stop()
    }

    private func start() {
        guard let listRef = MTDeviceCreateList()?.takeRetainedValue() as? [MTDeviceRef] else { return }
        devices = listRef
        for device in devices {
            let selfPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            MTRegisterContactFrameCallback(device, { device, contacts, count, timestamp, frame, refcon in
                if let refcon = refcon {
                    let monitor = Unmanaged<MultiTouchMonitor>.fromOpaque(refcon).takeUnretainedValue()
                    monitor.handle(contacts: contacts, count: Int(count))
                }
            }, selfPtr)
            MTDeviceStart(device, 0)
        }
    }

    private func stop() {
        for device in devices {
            MTDeviceStop(device)
        }
        devices.removeAll()
    }

    private func handle(contacts: UnsafeMutablePointer<MTContact>?, count: Int) {
        guard let contacts = contacts, count == 4 else { return }
        let contactArray = Array(UnsafeBufferPointer(start: contacts, count: count))
        // simple downward check using average y delta between contacts
        let avgY = contactArray.map { $0.normalized.y }.reduce(0, +) / Float(count)
        if avgY < -0.5 { // downward movement threshold
            DispatchQueue.main.async {
                self.callback()
            }
        }
    }
}
