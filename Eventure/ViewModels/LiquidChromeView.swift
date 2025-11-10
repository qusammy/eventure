import SwiftUI
import MetalKit

struct LiquidChromeView: UIViewRepresentable {
    var baseColor: SIMD3<Float> = [0, 0.627, 0.702]
    var speed: Float = 0.2
    var amplitude: Float = 0.3
    var freqX: Float = 3.0
    var freqY: Float = 3.0
    var interactive: Bool = true

    func makeCoordinator() -> Renderer {
        Renderer(baseColor: baseColor, speed: speed, amplitude: amplitude, freqX: freqX, freqY: freqY)
    }

    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.delegate = context.coordinator
        mtkView.framebufferOnly = false
        mtkView.isPaused = false
        mtkView.enableSetNeedsDisplay = false
        mtkView.preferredFramesPerSecond = 60
        return mtkView
    }

    func updateUIView(_ uiView: MTKView, context: Context) { }
}

// MARK: - Renderer

final class Renderer: NSObject, MTKViewDelegate {
    var pipelineState: MTLRenderPipelineState!
    var startTime = CACurrentMediaTime()
    var baseColor: SIMD3<Float>
    var speed, amplitude, freqX, freqY: Float

    init(baseColor: SIMD3<Float>, speed: Float, amplitude: Float, freqX: Float, freqY: Float) {
        self.baseColor = baseColor
        self.speed = speed
        self.amplitude = amplitude
        self.freqX = freqX
        self.freqY = freqY
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}

    func draw(in view: MTKView) {
        guard
            let device = view.device,
            let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
        else { return }

        if pipelineState == nil {
            let library = device.makeDefaultLibrary()
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = library?.makeFunction(name: "vertex_main")
            pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragment_main")
            pipelineDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat
            pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }

        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let encoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)

        let time = Float((CACurrentMediaTime() - startTime) * Double(speed))
        var resolution = SIMD2<Float>(Float(view.drawableSize.width), Float(view.drawableSize.height))
        var mouse = SIMD2<Float>(0, 0)

        encoder?.setRenderPipelineState(pipelineState)
        encoder?.setVertexBytes([Float](repeating: 0, count: 0), length: 0, index: 0)
        encoder?.setFragmentBytes([time], length: MemoryLayout<Float>.size, index: 0)
        encoder?.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 1)
        encoder?.setFragmentBytes(&baseColor, length: MemoryLayout<SIMD3<Float>>.size, index: 2)
        encoder?.setFragmentBytes(&amplitude, length: MemoryLayout<Float>.size, index: 3)
        encoder?.setFragmentBytes(&freqX, length: MemoryLayout<Float>.size, index: 4)
        encoder?.setFragmentBytes(&freqY, length: MemoryLayout<Float>.size, index: 5)
        encoder?.setFragmentBytes(&mouse, length: MemoryLayout<SIMD2<Float>>.size, index: 6)

        encoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
