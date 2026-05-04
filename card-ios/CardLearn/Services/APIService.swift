import Foundation

/// 统一API服务门面，委托给各模块服务
/// 保持向后兼容，已有代码通过 APIService.shared 调用无需修改
class APIService {
    static let shared = APIService()

    // MARK: - 模块服务实例

    private let cardApi = CardApiService.shared
    private let authApi = AuthApiService.shared
    private let feedbackApi = FeedbackApiService.shared
    private let commentApi = CommentApiService.shared
    private let noteApi = NoteApiService.shared
    private let learningApi = LearningApiService.shared
    private let userCardApi = UserCardApiService.shared

    // MARK: - 小程序 API (CardApiService)

    func getMajorList() async throws -> [Major] {
        try await cardApi.getMajorList()
    }

    func getSubjectList(majorId: Int?) async throws -> [Subject] {
        try await cardApi.getSubjectList(majorId: majorId)
    }

    func getCardPage(subjectId: Int?, frontContent: String?, appUserId: Int?, status: String?, startDate: String? = nil, endDate: String? = nil, pageNum: Int = 1, pageSize: Int = AppPageSize.cards) async throws -> PageResponse<Card> {
        try await cardApi.getCardPage(subjectId: subjectId, frontContent: frontContent, appUserId: appUserId, status: status, startDate: startDate, endDate: endDate, pageNum: pageNum, pageSize: pageSize)
    }

    func getCardById(cardId: Int, appUserId: Int?) async throws -> Card {
        try await cardApi.getCardById(cardId: cardId, appUserId: appUserId)
    }

    func updateProgress(cardId: Int, appUserId: Int?, status: Int, token: String?) async throws {
        try await cardApi.updateProgress(cardId: cardId, appUserId: appUserId, status: status, token: token)
    }

    func getSubjectStats(subjectId: Int, appUserId: Int?) async throws -> SubjectStats {
        try await cardApi.getSubjectStats(subjectId: subjectId, appUserId: appUserId)
    }

    func getSprintConfig() async throws -> SprintConfig {
        try await cardApi.getSprintConfig()
    }

    func invalidateSprintConfigCache() {
        cardApi.invalidateSprintConfigCache()
    }

    func getRecommendCards(majorId: Int?) async throws -> [Card] {
        try await cardApi.getRecommendCards(majorId: majorId)
    }

    func getProgressStats(appUserId: Int?) async throws -> StudyStats {
        try await cardApi.getProgressStats(appUserId: appUserId)
    }

    // MARK: - 认证相关 API (AuthApiService)

    func getCaptcha() async throws -> CaptchaResponse {
        try await authApi.getCaptcha()
    }

    func login(username: String, password: String, captcha: String, captchaKey: String) async throws -> LoginResponse {
        try await authApi.login(username: username, password: password, captcha: captcha, captchaKey: captchaKey)
    }

    // MARK: - 反馈相关 API (FeedbackApiService)

    func submitFeedback(appUserId: Int, cardId: Int?, majorId: Int?, subjectId: Int?, type: String, rating: Int?, content: String, contact: String?, images: [String]?, token: String) async throws {
        try await feedbackApi.submitFeedback(appUserId: appUserId, cardId: cardId, majorId: majorId, subjectId: subjectId, type: type, rating: rating, content: content, contact: contact, images: images, token: token)
    }

    func getUserFeedbackList(appUserId: Int, pageNum: Int = 1, pageSize: Int = AppPageSize.feedback, token: String) async throws -> PageResponse<Feedback> {
        try await feedbackApi.getUserFeedbackList(appUserId: appUserId, pageNum: pageNum, pageSize: pageSize, token: token)
    }

    // MARK: - 进度卡片 API (CardApiService)

    func getProgressCards(appUserId: Int, status: String, pageNum: Int = 1, pageSize: Int = AppPageSize.cards) async throws -> PageResponse<Card> {
        try await cardApi.getCardPage(subjectId: nil, frontContent: nil, appUserId: appUserId, status: status, pageNum: pageNum, pageSize: pageSize)
    }

    // MARK: - 用户卡片贡献 API (UserCardApiService)

    func createCard(subjectId: Int, frontContent: String, backContent: String, difficultyLevel: Int, tagIds: [Int]?, token: String) async throws -> Int {
        try await userCardApi.createCard(subjectId: subjectId, frontContent: frontContent, backContent: backContent, difficultyLevel: difficultyLevel, tagIds: tagIds, token: token)
    }

    func getMyCards(auditStatus: String?, pageNum: Int = 1, pageSize: Int = AppPageSize.myCards, token: String) async throws -> PageResponse<MyCard> {
        try await userCardApi.getMyCards(auditStatus: auditStatus, pageNum: pageNum, pageSize: pageSize, token: token)
    }

    func getMyCardStats(token: String) async throws -> MyCardStats {
        try await userCardApi.getMyCardStats(token: token)
    }

    func deleteMyCard(draftId: Int, token: String) async throws {
        try await userCardApi.deleteMyCard(draftId: draftId, token: token)
    }

    // MARK: - 评论 API (CommentApiService)

    func submitComment(cardId: Int, appUserId: Int, content: String, rating: Int, commentType: String, isNote: Int = 0) async throws -> Int {
        try await commentApi.submitComment(cardId: cardId, appUserId: appUserId, content: content, rating: rating, commentType: commentType, isNote: isNote)
    }

    func getCardComments(cardId: Int, pageNum: Int = 1, pageSize: Int = AppPageSize.comments, userId: Int? = nil) async throws -> PageResponse<Comment> {
        try await commentApi.getCardComments(cardId: cardId, pageNum: pageNum, pageSize: pageSize, userId: userId)
    }

    func getCommentStats(cardId: Int) async throws -> CommentStats {
        try await commentApi.getCommentStats(cardId: cardId)
    }

    func toggleCommentLike(commentId: Int, userId: Int, likeType: Int) async throws -> Int {
        try await commentApi.toggleCommentLike(commentId: commentId, userId: userId, likeType: likeType)
    }

    func getReplies(commentId: Int, pageNum: Int = 1, pageSize: Int = 20, userId: Int? = nil) async throws -> PageResponse<Reply> {
        try await commentApi.getReplies(commentId: commentId, pageNum: pageNum, pageSize: pageSize, userId: userId)
    }

    func submitReply(commentId: Int, userId: Int, content: String) async throws -> Int {
        try await commentApi.submitReply(commentId: commentId, userId: userId, content: content)
    }

    func toggleReplyLike(replyId: Int, userId: Int, likeType: Int) async throws -> Int {
        try await commentApi.toggleReplyLike(replyId: replyId, userId: userId, likeType: likeType)
    }

    // MARK: - 笔记相关 API (NoteApiService)

    func getMyNotes(userId: Int, subjectId: Int? = nil, keyword: String? = nil, pageNum: Int = 1, pageSize: Int = AppPageSize.comments) async throws -> PageResponse<Note> {
        try await noteApi.getMyNotes(userId: userId, subjectId: subjectId, keyword: keyword, pageNum: pageNum, pageSize: pageSize)
    }

    func editNote(noteId: Int, userId: Int, content: String) async throws {
        try await noteApi.editNote(noteId: noteId, userId: userId, content: content)
    }

    func deleteNote(noteId: Int, userId: Int) async throws {
        try await noteApi.deleteNote(noteId: noteId, userId: userId)
    }

    func exportNotes(userId: Int, subjectId: Int? = nil) async throws -> String {
        try await noteApi.exportNotes(userId: userId, subjectId: subjectId)
    }

    // MARK: - SM-2 学习进度相关 API (LearningApiService)

    func getSM2Progress(cardId: Int, appUserId: Int?) async throws -> SM2Progress {
        try await learningApi.getSM2Progress(cardId: cardId, appUserId: appUserId)
    }

    func submitSM2Review(request: ReviewSubmitRequest, token: String?) async throws {
        try await learningApi.submitSM2Review(request: request, token: token)
    }

    func submitSimpleReview(cardId: Int, userId: Int?, status: Int) async throws -> ReviewResultVO {
        try await learningApi.submitSimpleReview(cardId: cardId, userId: userId, status: status)
    }

    func getReviewPlan(appUserId: Int?) async throws -> [ReviewPlanResponse] {
        try await learningApi.getReviewPlan(appUserId: appUserId)
    }

    func getCardStudyHistory(cardId: Int, userId: Int) async throws -> CardStudyHistoryResponse {
        try await learningApi.getCardStudyHistory(cardId: cardId, userId: userId)
    }

    func getSubjectProgress(appUserId: Int?) async throws -> [SubjectProgressResponse] {
        try await learningApi.getSubjectProgress(appUserId: appUserId)
    }

    func getLearningStats(appUserId: Int?) async throws -> LearningStatsResponse {
        try await learningApi.getLearningStats(appUserId: appUserId)
    }

    func registerDevice(userId: Int, deviceToken: String, deviceType: String) async throws {
        try await learningApi.registerDevice(userId: userId, deviceToken: deviceToken, deviceType: deviceType)
    }
}
