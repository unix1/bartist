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
            .background(Color(uiColor: .systemBackground))
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
    private let creditView = MapCreditView()
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
        backgroundColor = .systemBackground
        imageView.isUserInteractionEnabled = true
        addSubview(imageView)
        addSubview(creditView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        tap.numberOfTapsRequired = 2
        addGestureRecognizer(tap)
        setImageName(imageName)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        fittedForSize = .zero
        scheduleFit()
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
        positionCredit()
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
        positionCredit()
        fittedForSize = bounds.size
        isFitting = false
    }

    private func alignImage() {
        let extraX = max((bounds.width - contentSize.width) * 0.5, 0)
        let extraY = max(bounds.height - contentSize.height, 0)
        contentInset = UIEdgeInsets(top: 0, left: extraX, bottom: extraY, right: extraX)
        positionCredit()
    }

    private func positionCredit() {
        let size = creditView.sizeThatFits(CGSize(width: 200, height: 20))
        creditView.frame.size = size
        creditView.frame.origin = CGPoint(
            x: imageView.frame.maxX - size.width - 8,
            y: imageView.frame.maxY - size.height - 6
        )
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

private final class MapCreditView: UITextView, UITextViewDelegate {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        isEditable = false
        isScrollEnabled = false
        isSelectable = true
        backgroundColor = .clear
        textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
        let color = UIColor(red: 92 / 255, green: 92 / 255, blue: 92 / 255, alpha: 0.8)
        linkTextAttributes = [.foregroundColor: color, .underlineStyle: 0]
        let font = UIFont.systemFont(ofSize: 10)
        let text = NSMutableAttributedString()
        let body: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        text.append(NSAttributedString(string: "© ", attributes: body))
        text.append(NSAttributedString(string: "BART", attributes: body.merging([
            .link: URL(string: "https://www.bart.gov/schedules/developers/maps")!,
        ]) { _, new in new }))
        text.append(NSAttributedString(string: " · ", attributes: body))
        text.append(NSAttributedString(string: "CC BY 3.0", attributes: body.merging([
            .link: URL(string: "https://creativecommons.org/licenses/by/3.0/")!,
        ]) { _, new in new }))
        attributedText = text
        delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
}
