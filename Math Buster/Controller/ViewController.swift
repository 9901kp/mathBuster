//
//  ViewController.swift
//  Math Buster
//
//  Created by Мухаммед Каипов on 18/4/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var problemLabel: UILabel!
    @IBOutlet var timerContainer: UIView!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var resultField: UITextField!
    @IBOutlet var submit: UIButton!
    @IBOutlet var restart: UIButton!
    @IBOutlet var segmentController: UISegmentedControl!
    
    var dataModel: ViewControllerDataModel = ViewControllerDataModel()
    
    // Функция вызывается при загрузке представления
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Score: 0"
        setUpUI() // Настройка пользовательского интерфейса
        generateProblem() // Генерация первой задачи
    }
    
    // Функция вызывается при появлении представления
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scheduledTimer() // Запуск таймера
    }
    
    // Настройка пользовательского интерфейса
    func setUpUI() {
        timerContainer.layer.cornerRadius = 5
        resultField.keyboardType = .decimalPad
    }

    // Генерация новой арифметической задачи
    func generateProblem() {
        let selectedIndex = segmentController.selectedSegmentIndex
        let range = dataModel.ranges[selectedIndex]
        
        let firstDig = Int.random(in: range)
        let arithmetic: String = ["+","-","*","/"].randomElement()!
        
        var startInt = range.lowerBound
        var endInt = range.upperBound
        if arithmetic == "/" && startInt == 0 {
            startInt = 1
        } else if arithmetic == "-" {
            endInt = firstDig
        }
        let secondDig = Int.random(in: startInt...endInt)
        
        problemLabel.text = "\(firstDig)\(arithmetic)\(secondDig)"
        
        switch arithmetic {
        case "+":
            dataModel.result = Double(firstDig + secondDig)
        case "-":
            dataModel.result = Double(firstDig - secondDig)
        case "*":
            dataModel.result = Double(firstDig * secondDig)
        case "/":
            dataModel.result = Double(firstDig) / Double(secondDig)
        default:
            dataModel.result = nil
        }
    }

    // Запуск таймера
    func scheduledTimer() {
        dataModel.countDown = 10
        dataModel.timer?.invalidate()
        dataModel.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    // Обновление таймера каждую секунду
    @objc
    func updateTimer() {
        dataModel.countDown -= 1
        timerLabel.text = "00:\(dataModel.countDown)"
        if dataModel.countDown < 10 {
            timerLabel.text = "00:0\(dataModel.countDown)"
        }
        progressView.progress = Float(30 - dataModel.countDown) / 30
        
        if dataModel.countDown <= 0 {
            finishGame() // Завершение игры, если время истекло
        }
    }
    // Завершение игры
    func finishGame() {
        dataModel.timer?.invalidate()
        resultField.isEnabled = false
        submit.isEnabled = false
        
        askForName() // Запрос имени пользователя
    }
    
    // Обработка нажатия на кнопку "Submit"
    @IBAction func submitPressed(_ sender: Any) {
        guard let text = resultField.text else {
            print("Text is nil")
            return
        }
        guard !text.isEmpty else {
            print("Text is empty")
            return
        }
        
        guard let newRes = Double(text) else {
            print("We can not convert \(text) to Double")
            return
        }
        
        if newRes == dataModel.result {
            print("Correct")
            let selectedIndex = segmentController.selectedSegmentIndex
            dataModel.score += dataModel.scoreAmount[selectedIndex]
            scoreLabel.text = "Score: \(dataModel.score)"
        } else {
            print("incorrect")
        }
        generateProblem() // Генерация новой задачи
        resultField.text = "" // Очистка поля ввода
    }
    
    // Обработка нажатия на кнопку "Restart"
    @IBAction func restartPressed(_ sender: Any) {
        newRestartFunc() // Перезапуск игры
    }
    
    // Функция перезапуска игры
    func newRestartFunc() {
        dataModel.score = 0
        scoreLabel.text = "Score: \(dataModel.score)"
        
        generateProblem() // Генерация новой задачи
        scheduledTimer() // Перезапуск таймера
        
        resultField.isEnabled = true
        submit.isEnabled = true
    }
    
    // Обработка изменения сегмента в контроллере сегментов
    @IBAction func segmentedController(_ sender: UISegmentedControl) {
        newRestartFunc() // Перезапуск игры
    }
    

    
    // Запрос имени пользователя для сохранения результата
    func askForName() {
        let alertController = UIAlertController(title: "Game is Over", message: "Score: \(dataModel.score)", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter your Name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let textField = alertController.textFields?.first else {
                print("TextField is absent")
                return
            }
            guard let text = textField.text, !text.isEmpty else {
                print("Text is nil or empty")
                return
            }
            print("Name: \(text)")
            
            self.saveUserScoreAsStruct(name: text) // Сохранение результата
        }
        alertController.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let skipAction = UIAlertAction(title: "Skip", style: .destructive)
        alertController.addAction(skipAction)
        
        present(alertController, animated: true)
    }
    
//    Сохраняет результат пользователя в виде структуры UserScoreStruct и сохраняет данные в UserDefaults.
    func saveUserScoreAsStruct(name: String) {
        let scoreOfUsers: UserScoreStruct = UserScoreStruct(name: name, score: dataModel.score)
        
        var level: Level?
        switch segmentController.selectedSegmentIndex {
        case 0:
            level = .easy
        case 1:
            level = .medium
        case 2:
            level = .hard
        default:
            ()
        }
        guard let level = level else {
            return
        }
        
        let userScoreArray: [UserScoreStruct] = ViewController.getAllUserScore(level: level) + [scoreOfUsers]
        
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(userScoreArray)
            let userDefaults = UserDefaults.standard
            userDefaults.set(encodedData, forKey: level.key())
        } catch {
            print("Couldn't convert given [UserScore] into data with error: \(error.localizedDescription)")
        }
    }
    
    // Возвращает массив всех результатов пользователей для заданного уровня сложности из UserDefaults.
    static func getAllUserScore(level: Level) -> [UserScoreStruct] {
        var result: [UserScoreStruct] = []
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.object(forKey: level.key()) as? Data {
            do {
                let decoder = JSONDecoder()
                result = try decoder.decode([UserScoreStruct].self, from: data)
            } catch {
                print("Couldn't decode given data to [UserScore] with error: \(error.localizedDescription)")
            }
        }
        return result
    }
    
    // Сохранение результата пользователя в виде словаря
    func saveUserScore(name: String) {
        let userScore: [String: Any] = ["name": name, "score": dataModel.score]
        let userScoreArr: [[String: Any]] = getUserScoreArr() + [userScore]
        
        let userDefault = UserDefaults.standard
        userDefault.set(userScoreArr, forKey: ViewControllerDataModel.userScoreKey)
    }
    
    // Получение массива результатов пользователей в виде словарей
    func getUserScoreArr() -> [[String: Any]] {
        let userDefault = UserDefaults.standard
        let array = userDefault.array(forKey: ViewControllerDataModel.userScoreKey) as? [[String: Any]]
        return array ?? []
    }
}

struct ViewControllerDataModel {
    var timer: Timer?
    var countDown = 30
    var result: Double?
    var score: Int = 0
    let ranges = [0...9, 10...99, 100...999]
    var scoreAmount = [1, 2, 3]
    
    static let userScoreKey: String = "g"
}

struct UserScoreStruct: Codable {
    let name: String
    let score: Int
}

enum Level {
    case easy
    case medium
    case hard
    
    func key() -> String {
        switch self {
        case .easy:
            return "easyUserScore"
        case .medium:
            return "mediumUserScore"
        case .hard:
            return "hardUserScore"
        }
    }
}
