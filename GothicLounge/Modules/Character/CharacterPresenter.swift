import Foundation
import Combine

@MainActor final class CharacterPresenter: ObservableObject, CharacterPresenterInput {
    @Published private(set) var state = CharacterState()
    @Published var filter: AchievementFilter = .all
    private let interactor: any CharacterInteractorInput
    private let router: any CharacterRouterInput
    private var subscription: AnyCancellable?

    var visibleAchievements: [AchievementState] {
        state.achievements.filter { filter == .all || (filter == .earned ? $0.unlocked : !$0.unlocked) }
    }

    init(interactor: any CharacterInteractorInput, router: any CharacterRouterInput) {
        self.interactor = interactor
        self.router = router
        subscription = interactor.changes.sink { [weak self] in self?.refresh() }
        refresh()
    }
    func refresh() {
        let snapshot = interactor.fetch()
        let progress = snapshot.levelProgress
        let achievements = snapshot.achievements.map { achievement in
            AchievementState(id: achievement.id, title: achievement.definition.title, icon: achievement.definition.icon,
                unlocked: achievement.unlocked, explanation: achievement.definition.detail,
                progress: achievement.fraction, counter: "\(min(achievement.value, achievement.definition.target)) / \(achievement.definition.target)")
        }
        state = CharacterState(name: snapshot.realm.name, rank: "ОБЩИЙ УРОВЕНЬ", level: "\(progress.level)",
            xp: "\(progress.earned) / \(progress.required) XP", progress: progress.fraction,
            skills: Skill.allCases.map { skill in
                let item = snapshot.skillProgress[skill] ?? LevelProgress(level: 1, earned: 0, required: 200)
                return SkillState(skill: skill, level: "\(item.level)", xp: "\(item.earned) / \(item.required) XP", progress: item.fraction)
            }, achievements: achievements,
            achievementSummary: "\(achievements.filter(\.unlocked).count) / \(achievements.count)",
            bestStreak: "\(snapshot.bestStreak)", activeDays: "\(snapshot.activeDays)",
            totalXP: "\(snapshot.xp)", totalCompletions: "\(snapshot.realm.completions.count)", ambience: snapshot.realm.ambience)
    }
    func explain(_ achievement: AchievementState) {
        router.show(title: achievement.title,
                    text: achievement.explanation + "\n\nПрогресс: " + achievement.counter + (achievement.unlocked ? " · Получено" : ""),
                    icon: achievement.icon)
    }
    func explainSkill(_ skill: Skill) {
        router.show(title: skill.title, text: skill.examples + ".\n\nВыбирайте эту характеристику при создании привычки. Опыт развивает её и ваш общий уровень одновременно.", icon: skill.icon)
    }
    func explainLevel() {
        router.show(title: "Как растёт уровень", text: "Первый переход стоит 200 XP. Каждый следующий — на 75 XP больше: 275, 350, 425…\n\nУ характеристик такая же шкала. Отмена выполнения убирает начисленный опыт. Каждый пятый общий уровень отмечается поздравлением.", icon: "chart.line.uptrend.xyaxis")
    }
}
