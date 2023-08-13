//
//  NewWishDetailVC.swift
//  
//
//  Created by Martin Lasek on 8/12/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

#if canImport(UIKit)
import UIKit
import WishKitShared
import SwiftUI

final class DetailWishVC: UIViewController {

    private let wishResponse: WishResponse

    private let doneContainer = UIView()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(WishKit.config.localization.done, for: .normal)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        button.layer.opacity = 0
        return button
    }()

    private let wishView: UIView

    private let voteButton = VoteButton()

    private let commentSeparator: UIView = {
        let view = UIHostingController(rootView: SeparatorView()).view ?? UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let commentListView: UIView

    init(wishResponse: WishResponse) {
        self.wishResponse = wishResponse

        let wishView = WKWishView(title: wishResponse.title, description: wishResponse.description)
        self.wishView = UIHostingController(rootView: wishView).view

        let commentListView = CommentListView(commentList: [
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
            CommentResponse(userId: UUID(), description: "Hey! Listen!", createdAt: Date(), isAdmin: .random()),
        ])

        self.commentListView = UIHostingController(rootView: commentListView).view

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateDoneButton()
    }

    // MARK: - Setup View

    private func setupView() {

        setupNavigation()
        setupDoneButton()
        setupWishView()
        setupVoteButton()
        setupCommentSeparatorView()
        setupCommentListView()

        setupTheme()
    }

    private func setupNavigation() {
        navigationItem.title = WishKit.config.localization.detail
    }

    private func setupDoneButton() {
        view.addSubview(doneContainer)
        doneContainer.addSubview(doneButton)

        doneContainer.anchor(
            top: view.layoutMarginsGuide.topAnchor,
            trailing: view.trailingAnchor,
            size: CGSize(width: 0, height: 35)
        )

        doneButton.anchor(
            top: doneContainer.topAnchor,
            leading: doneContainer.leadingAnchor,
            bottom: doneContainer.bottomAnchor,
            trailing: doneContainer.trailingAnchor,
            padding: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 65)
        )
    }

    private func setupWishView() {
        view.addSubview(wishView)

        wishView.translatesAutoresizingMaskIntoConstraints = false

        wishView.anchor(
            top: doneContainer.bottomAnchor,
            leading: view.layoutMarginsGuide.leadingAnchor,
            trailing: view.layoutMarginsGuide.trailingAnchor,
            padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        )

        wishView.backgroundColor = .clear
    }

    private func setupVoteButton() {
        view.addSubview(voteButton)

        voteButton.anchor(
            top: wishView.bottomAnchor,
            centerX: view.layoutMarginsGuide.centerXAnchor,
            padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            size: CGSize(width: 200, height: 0)
        )

        voteButton.addTarget(self, action: #selector(voteAction), for: .touchUpInside)
        voteButton.voteCountLabel.text = String(describing: wishResponse.votingUsers.count)
    }

    private func setupCommentSeparatorView() {
        view.addSubview(commentSeparator)

        commentSeparator.translatesAutoresizingMaskIntoConstraints = false

        commentSeparator.anchor(
            top: voteButton.bottomAnchor,
            leading: view.leadingAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        )
    }

    private func setupCommentListView() {
        view.addSubview(commentListView)

        commentListView.translatesAutoresizingMaskIntoConstraints = false

        commentListView.anchor(
            top: commentSeparator.bottomAnchor,
            leading: view.leadingAnchor,
//            bottom: view.bottomAnchor,
            trailing: view.trailingAnchor,
            padding: UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
        )

        commentListView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
    }

    // MARK: - WishKit Color

    private func setupTheme() {

        // Background Color
        if let color = WishKit.theme.tertiaryColor {
            if traitCollection.userInterfaceStyle == .light {
                view.backgroundColor = UIColor(color.light)
            }

            if traitCollection.userInterfaceStyle == .dark {
                view.backgroundColor = UIColor(color.dark)
            }
        } else {
            view.backgroundColor = .secondarySystemBackground
        }
    }
}

// MARK: - Logic

extension DetailWishVC {
    private func handleVoteSuccess(response: VoteWishResponse) {
        voteButton.voteCountLabel.text = String(describing: response.votingUsers.count)
    }

    private func handleVoteError(error: ApiError) {
        AlertManager.confirmMessage(on: self, message: error.reason.description)
    }
}

// MARK: - Action

extension DetailWishVC {

    @objc private func dismissAction() {
        dismiss(animated: true)
    }

    @objc private func voteAction() {

        // Check if it'syour own wish.
        if wishResponse.userUUID == UUIDManager.getUUID() {
            AlertManager.confirmMessage(on: self, message: WishKit.config.localization.youCanNotVoteForYourOwnWish)
            return
        }

        // Check if you already voted.
        if wishResponse.votingUsers.contains(where: {$0.uuid == UUIDManager.getUUID() }) {
            AlertManager.confirmMessage(on: self, message: WishKit.config.localization.youCanOnlyVoteOnce)
            return
        }

        let voteRequest = VoteWishRequest(wishId: wishResponse.id)

        WishApi.voteWish(voteRequest: voteRequest) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let wishResponse):
                    self.handleVoteSuccess(response: wishResponse)
                case .failure(let error):
                    self.handleVoteError(error: error)
                }
            }
        }
    }
}

// MARK: - Landscape

extension DetailWishVC {

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateDoneButton()
    }

    func updateDoneButton() {
        guard let bounds = view.window?.screen.bounds else {
            return
        }

        if bounds.width > bounds.height {
            UIView.animate(withDuration: 1/6) {
                self.doneButton.layer.opacity = 1
            }
        } else {
            UIView.animate(withDuration: 1/6) {
                self.doneButton.layer.opacity = 0
            }
        }
    }
}

// MARK: - Dark Mode

extension DetailWishVC {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            let previousTraitCollection = previousTraitCollection
        else {
            return
        }

        // Background
        if let color = WishKit.theme.tertiaryColor {
            // Needed this case where it's the same, there's a weird behaviour otherwise.
            if traitCollection.userInterfaceStyle == previousTraitCollection.userInterfaceStyle {
                if previousTraitCollection.userInterfaceStyle == .light {
                    view.backgroundColor = UIColor(color.light)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    view.backgroundColor = UIColor(color.dark)
                }
            } else {
                if previousTraitCollection.userInterfaceStyle == .light {
                    view.backgroundColor = UIColor(color.dark)
                }

                if previousTraitCollection.userInterfaceStyle == .dark {
                    view.backgroundColor = UIColor(color.light)
                }
            }
        }
    }
}
#endif

