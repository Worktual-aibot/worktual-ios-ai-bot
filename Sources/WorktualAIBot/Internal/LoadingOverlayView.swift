import UIKit

final class LoadingOverlayView: UIView {

    private let config: WorktualAIBotConfig
    private let progressFill = UIView()
    private let subtitleLabel = UILabel()
    private var progressWidthConstraint: NSLayoutConstraint!
    private var pulseTimer: Timer?
    private let trackWidth: CGFloat = 200

    init(config: WorktualAIBotConfig) {
        self.config = config
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    // MARK: - UI Setup

    private func setupUI() {
        backgroundColor = config.loadingBackground
        isUserInteractionEnabled = true // block touches

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -40)
        ])

        // Logo or Spinner
        if let logo = config.loadingLogo {
            let imageView = UIImageView(image: logo)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: config.loadingLogoWidth),
                imageView.heightAnchor.constraint(equalToConstant: config.loadingLogoHeight)
            ])
            stack.addArrangedSubview(imageView)
            stack.setCustomSpacing(20, after: imageView)
        } else {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = config.primaryColor
            spinner.startAnimating()
            stack.addArrangedSubview(spinner)
            stack.setCustomSpacing(20, after: spinner)
        }

        // Title
        let titleLabel = UILabel()
        titleLabel.text = config.loadingTitle
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.18, alpha: 1.0)
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)

        // Subtitle
        subtitleLabel.text = config.loadingSubtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.63, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        stack.addArrangedSubview(subtitleLabel)
        stack.setCustomSpacing(28, after: subtitleLabel)

        // Progress track
        let track = UIView()
        track.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.91, alpha: 1.0)
        track.layer.cornerRadius = 2
        track.clipsToBounds = true
        track.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            track.widthAnchor.constraint(equalToConstant: trackWidth),
            track.heightAnchor.constraint(equalToConstant: 4)
        ])
        stack.addArrangedSubview(track)

        // Progress fill
        progressFill.backgroundColor = config.primaryColor
        progressFill.layer.cornerRadius = 2
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(progressFill)

        progressWidthConstraint = progressFill.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressFill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: track.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            progressWidthConstraint
        ])
    }

    // MARK: - Animations

    func startAnimations() {
        // Progress: fast to 70% in 0.8s, then slow to 90% in 2.5s
        progressWidthConstraint.constant = 0
        layoutIfNeeded()

        UIView.animate(withDuration: 0.8, delay: 0, options: .curveLinear) {
            self.progressWidthConstraint.constant = self.trackWidth * 0.7
            self.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 2.5, delay: 0, options: .curveLinear) {
                self.progressWidthConstraint.constant = self.trackWidth * 0.9
                self.layoutIfNeeded()
            }
        }

        // Pulse subtitle
        startPulse()
    }

    private func startPulse() {
        pulseTimer?.invalidate()
        animatePulse(toAlpha: 0.3)
    }

    private func animatePulse(toAlpha: CGFloat) {
        UIView.animate(withDuration: 0.5, animations: {
            self.subtitleLabel.alpha = toAlpha
        }) { _ in
            guard self.superview != nil else { return }
            self.animatePulse(toAlpha: toAlpha == 0.3 ? 1.0 : 0.3)
        }
    }

    func completeAndHide(completion: @escaping () -> Void) {
        // Complete progress to 100% in 150ms
        UIView.animate(withDuration: 0.15) {
            self.progressWidthConstraint.constant = self.trackWidth
            self.layoutIfNeeded()
        }

        // Fade out after 150ms
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0
            }) { _ in
                self.isHidden = true
                self.removeFromSuperview()
                completion()
            }
        }
    }

    func cleanup() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        layer.removeAllAnimations()
        subtitleLabel.layer.removeAllAnimations()
    }
}
