import SwiftUI
import UIKit

struct MapView: View {
    @State private var period = MapPeriod.current()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                BrandTitle(title: "Map")
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                ZStack(alignment: .top) {
                    ZoomableImageView(imageName: period.assetName)
                        .ignoresSafeArea(edges: .bottom)

                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            periodButton(.day, label: "☀️", accessibility: "Daytime map")
                            periodButton(.evening, label: "🌙", accessibility: "Evening map")
                        }
                        .background(.regularMaterial, in: Capsule())
                        .overlay(Capsule().strokeBorder(.separator, lineWidth: 0.5))
                        .padding(.bottom, 12)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .background(Palette.background.ignoresSafeArea())
            .accessibilityIdentifier("map-screen")
        }
    }

    private func periodButton(_ value: MapPeriod, label: String, accessibility: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.28)) {
                period = value
            }
        } label: {
            Text(label)
                .frame(width: 40, height: 36)
                .background(period == value ? Color.accentColor.opacity(0.15) : .clear)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibility)
        .accessibilityAddTraits(period == value ? .isSelected : [])
    }
}

private enum MapPeriod {
    case day
    case evening

    var assetName: String {
        switch self {
        case .day: "MapDaytime"
        case .evening: "MapEvening"
        }
    }

    static func current() -> MapPeriod {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        let hour = calendar.component(.hour, from: Date())
        return (hour >= 21 || hour < 3) ? .evening : .day
    }
}

private struct ZoomableImageView: UIViewRepresentable {
    let imageName: String

    func makeUIView(context: Context) -> ZoomableScrollView {
        ZoomableScrollView(imageName: imageName)
    }

    func updateUIView(_ scrollView: ZoomableScrollView, context: Context) {
        scrollView.setImageName(imageName)
    }
}

private final class ZoomableScrollView: UIScrollView, UIScrollViewDelegate {
    private let imageView = UIImageView()
    private var imageName = ""
    private var fittedForSize: CGSize = .zero
    private var isFitting = false

    init(imageName: String) {
        super.init(frame: .zero)
        delegate = self
        minimumZoomScale = 1
        maximumZoomScale = 8
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bouncesZoom = true
        contentInsetAdjustmentBehavior = .never
        backgroundColor = Palette.backgroundUIColor
        addSubview(imageView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
        setImageName(imageName)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previous) else {
            return
        }
        let name = imageName
        imageName = ""
        setImageName(name)
    }

    func setImageName(_ name: String) {
        guard name != imageName else {
            return
        }
        imageName = name
        let next = UIImage(named: name)
        UIView.transition(with: imageView, duration: 0.28, options: .transitionCrossDissolve) {
            self.imageView.image = next
        }
        if let next, next.size != imageView.bounds.size, fittedForSize != .zero {
            imageView.frame = CGRect(origin: .zero, size: next.size)
            contentSize = next.size
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if !isFitting, fittedForSize != bounds.size {
            scheduleFit()
        } else if !isFitting {
            alignImage()
        }
    }

    private func scheduleFit() {
        DispatchQueue.main.async { [weak self] in
            self?.resetAndFit()
        }
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        alignImage()
    }

    private func resetAndFit() {
        guard !isFitting, fittedForSize != bounds.size else {
            return
        }
        guard bounds.width > 1, bounds.height > 1, let image = imageView.image, image.size.width > 1 else {
            return
        }

        isFitting = true
        zoomScale = 1
        minimumZoomScale = 1
        maximumZoomScale = 1
        imageView.transform = .identity
        imageView.frame = CGRect(origin: .zero, size: image.size)
        contentSize = image.size
        contentOffset = .zero
        contentInset = .zero

        let scale = min(bounds.width / image.size.width, bounds.height / image.size.height)
        minimumZoomScale = scale
        maximumZoomScale = scale * 8
        zoomScale = scale
        contentOffset = .zero
        alignImage()
        fittedForSize = bounds.size
        isFitting = false
    }

    private func alignImage() {
        let extraX = max((bounds.width - contentSize.width) * 0.5, 0)
        let extraY = max(bounds.height - contentSize.height, 0)
        contentInset = UIEdgeInsets(top: 0, left: extraX, bottom: extraY, right: extraX)
    }

    @objc private func handleDoubleTap(_ tap: UITapGestureRecognizer) {
        if zoomScale > minimumZoomScale * 1.05 {
            setZoomScale(minimumZoomScale, animated: true)
            return
        }
        let point = tap.location(in: imageView)
        let target = min(minimumZoomScale * 2.5, maximumZoomScale)
        zoom(to: zoomRect(for: target, centeredAt: point), animated: true)
    }

    private func zoomRect(for scale: CGFloat, centeredAt center: CGPoint) -> CGRect {
        let width = bounds.width / scale
        let height = bounds.height / scale
        return CGRect(x: center.x - width / 2, y: center.y - height / 2, width: width, height: height)
    }
}
