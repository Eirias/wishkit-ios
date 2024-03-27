//
//  WishView.swift
//  wishkit-ios
//
//  Created by Martin Lasek on 8/12/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

import SwiftUI
import WishKitShared

struct WishView: View {

    // Helps differentiate where this view is used (in the list or in detail view).
    enum ViewKind {
        case list
        case detail
    }

    @Environment(\.colorScheme)
    private var colorScheme

    @ObservedObject
    private var alertModel = AlertModel()

    @State
    private var voteCount = 0

    @State
    private var hasVoted = false

    private let wishResponse: WishResponse

    private let voteActionCompletion: () -> Void

    private let viewKind: ViewKind

    private var descriptionLineLimit: Int? {
        if viewKind == .detail {
            return nil
        }
        
        return WishKit.config.expandDescriptionInList ? nil : 1
    }

    init(wishResponse: WishResponse, viewKind: ViewKind, voteActionCompletion: @escaping (() -> Void)) {
        self.wishResponse = wishResponse
        self.viewKind = viewKind
        self.voteActionCompletion = voteActionCompletion
        self._voteCount = State(wrappedValue: wishResponse.votingUsers.count)
    }

    var body: some View {
        HStack(spacing: 0) {
            Button(action: voteAction) {
                VStack(spacing: 5) {
                    Image(systemName: "arrowtriangle.up.fill")
                        .imageScale(.medium)
                        .foregroundColor(arrowColor)
                    Text(String(describing: voteCount))
                        .font(WishKit.theme.font.defaultText)
                        .foregroundColor(textColor)
                        .frame(width: 35)
                }
                .padding([.leading, .trailing], 12)
                .cornerRadius(12)
            }
            .buttonStyle(.plain) // makes sure it looks good on macOS.
            .alert(isPresented: $alertModel.showAlert) {
                var title = Text(WishKit.config.localization.youCanNotVoteForYourOwnWish)
                switch alertModel.alertReason {
                case .alreadyVoted:
                    title = Text(WishKit.config.localization.youCanOnlyVoteOnce)
                case .alreadyImplemented:
                    title = Text(WishKit.config.localization.youCanNotVoteForAnImplementedWish)
                case .voteReturnedError(let error):
                    title = Text("Something went wrong during your vote. Try again later.\n\n\(error)")
                case .none:
                    title = Text(WishKit.config.localization.youCanNotVoteForYourOwnWish)
                default:
                    title = Text("Something went wrong during your vote. Try again later.")
                }

                return Alert(title: title)
            }

            VStack(spacing: 5) {
                HStack {
                    Text(wishResponse.title)
                        .foregroundColor(textColor)
                        .font(WishKit.theme.font.defaultText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(viewKind == .list ? 1 : nil)

                    Spacer()

                    if viewKind == .list && WishKit.config.statusBadge == .show {
                        Text(wishResponse.state.description.uppercased())
                            .opacity(0.8)
                            .font(WishKit.theme.font.defaultTextTinyMedium)
                            .padding(EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5))
                            .foregroundColor(.primary)
                            .background(badgeColor(for: wishResponse.state).opacity(1/3))
                            .cornerRadius(6)
                    }
                }

                HStack {
                    Text(wishResponse.description)
                        .foregroundColor(textColor)
                        .font(WishKit.theme.font.defaultTextSmall)
                        .multilineTextAlignment(.leading)
                        .lineLimit(descriptionLineLimit)
                    Spacer()
                }
            }
        }
        .padding([.top, .bottom, .trailing], 10)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: WishKit.config.cornerRadius, style: .continuous))
        .wkShadow()
    }

    func badgeColor(for wishState: WishState) -> Color {
        switch wishState {
        case .pending:
            return WishKit.theme.badgeColor.pending
        case .approved:
            return WishKit.theme.badgeColor.approved
        case .implemented:
            return WishKit.theme.badgeColor.implemented
        case .rejected:
            return WishKit.theme.badgeColor.rejected
        }
    }

    private func voteAction() {
        let userUUID = UUIDManager.getUUID()

        if wishResponse.state == .implemented {
            alertModel.alertReason = .alreadyImplemented
            alertModel.showAlert = true
            return
        }

        if wishResponse.votingUsers.contains(where: { user in user.uuid == userUUID }) || hasVoted {
            alertModel.alertReason = .alreadyVoted
            alertModel.showAlert = true
            return
        }

        let request = VoteWishRequest(wishId: wishResponse.id)
        WishApi.voteWish(voteRequest: request) { result in
            switch result {
            case .success:
                voteCount += 1
                hasVoted = true
                DispatchQueue.main.async {
                    voteActionCompletion()
                }
            case .failure(let error):
                alertModel.alertReason = .voteReturnedError(error.localizedDescription)
                alertModel.showAlert = true
            }
        }
    }
}

// MARK: - Darkmode

extension WishView {
    var arrowColor: Color {
        let userUUID = UUIDManager.getUUID()
        if wishResponse.votingUsers.contains(where: { user in user.uuid == userUUID }) || hasVoted {
            return WishKit.theme.primaryColor
        }

        switch colorScheme {
        case .light:
            return WishKit.config.buttons.voteButton.arrowColor.light
        case .dark:
            return WishKit.config.buttons.voteButton.arrowColor.dark
        }
    }

    var textColor: Color {
        switch colorScheme {
        case .light:

            if let color = WishKit.theme.textColor {
                return color.light
            }

            return .black
        case .dark:
            if let color = WishKit.theme.textColor {
                return color.dark
            }

            return .white
        }
    }

    var backgroundColor: Color {
        switch colorScheme {
        case .light:

            if let color = WishKit.theme.secondaryColor {
                return color.light
            }

            return PrivateTheme.elementBackgroundColor.light
        case .dark:
            if let color = WishKit.theme.secondaryColor {
                return color.dark
            }

            return PrivateTheme.elementBackgroundColor.dark
        }
    }
}
