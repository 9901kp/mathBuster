//
//  DetailViewController.swift
//  Math Buster
//
//  Created by Мухаммед Каипов on 25/4/24.
//

import UIKit


class DetailViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var dataSource: [[UserScoreStruct]] = [] {
        didSet{
            print("Value of variable 'userScoreArrayOfDict' was changed")
            tableView.reloadData() //reloadData -> для того чтобы обнавлять массив. Если будет новый игрок , значение(имя,score) будет сразу обновлятся. Не стоит закрыть приложение и заново открыть
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ScoreTableViewCell", bundle: nil), forCellReuseIdentifier: ScoreTableViewCell.identfier)
        tableView.dataSource = self //отвечает за предоставление данных, которые отображаются в таблице, а также за управление ее структурой, такой как количество секций и строк
        tableView.delegate = self //как реагировать на действия пользователя, такие как нажатие на ячейку или прокрутка.
//        tableView.rowHeight = 60
        tableView.refreshControl = UIRefreshControl() //Загрузка
        tableView.refreshControl?.addTarget(self, action: #selector(getUserScore), for: .valueChanged)
        //self -> потому что вызываемый
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserScore()
    }
    
    
    // Функция для получения текстового представления данных пользователя
    func getSingleUserText(indexPath: IndexPath) -> String? {
        let userScore: UserScoreStruct = dataSource[indexPath.section][indexPath.row]
//        guard let name = dictionary["name"] as? String, let score = dictionary["score"] as? Int  else {
//            return nil
//        }
        let text = "Name: \(userScore.name), Score: \(userScore.score)"
        return text
    }
    
    // Функция для получения данных пользователя
    @objc
    func getUserScore() {
//        let userDefault = UserDefaults.standard
//        guard let userScore = userDefault.array(forKey: ViewControllerDataModel.userScoreKey) else {
//            print("User defaults doesn't contain arr with key : \(ViewControllerDataModel.userScoreKey)")
//            return
//        }
//        
//        guard let userScoreArrayOfDict = userScore as? [[String: Any]] else{
//            print("Couldn't convert Any to [[String: Any]]")
//            return
//        }
        
//        self.userScoreArrayOfDictionary = ViewController.getAllUserScore() /*userScoreArrayOfDict*/
        
        //Принесли функцию из другого класса, чтобы код был коротким и чистым
        // Получение списков результатов для разных уровней сложности
        var easyScoreList = ViewController.getAllUserScore(level: .easy)
        easyScoreList.sort { score1, score2 in
            return score1.score > score2.score
        }
        var mediumScoreList = ViewController.getAllUserScore(level: .medium)
        mediumScoreList.sort { score1, score2 in
            return score1.score > score2.score
        }
        var hardScoreList = ViewController.getAllUserScore(level: .hard)
        hardScoreList.sort { score1, score2 in
            return score1.score > score2.score
        }
        
        // Обновление dataSource с новыми данными
        self.dataSource = [easyScoreList,mediumScoreList,hardScoreList]
        
        
        tableView.refreshControl?.endRefreshing()
//        var text: String = ""
//        
//        userScoreArrayOfDict.forEach{ dict in
//            let name = dict["name"] as! String
//            let score = dict["score"] as! Int
//            
//            text += "Name: \(name), Score: \(score) \n"
//        }
    }
    

}





//MARK: UITableViewDataSource & UITableViewDelegate

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    // Возвращает количество секций в таблице
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    // Возвращает количество строк в каждой секции таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count    }
    
    // Возвращает ячейку для отображения в таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //функция указать ячейку для отображение
        let cell = tableView.dequeueReusableCell(withIdentifier: ScoreTableViewCell.identfier, for: indexPath) as! ScoreTableViewCell
        
        
        cell.scoreTextLabel.text = getSingleUserText(indexPath: indexPath)
        
//        let dictionary: [String: Any] = userScoreArrayOfDict[indexPath.row]
//        if let name = dictionary["name"] as? String, let score = dictionary["score"] as? Int {
//            cell.scoreTextLabel.text = "Name: \(name), Score: \(score)"
//        }
//        cell.scoreTextLabel.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a"
        return cell
    }
    
    // Обработка выбора строки в таблице
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User selected row: \(indexPath.row)")
        tableView.deselectRow(at: indexPath, animated: true) //чтобы когда нажав на кнопку,задний фон ячейки не был серым надолго
        
        let viewController = ScoreDetailViewController()
        viewController.text = getSingleUserText(indexPath: indexPath)
        navigationController?.pushViewController(viewController, animated: true) //Этот код используется для перехода к новому экрану
    }
    
    // Возвращает заголовок для каждой секции таблицы
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case 0:
            return "Easy"
        case 1:
            return "Medium"
        case 2:
            return "Hard"
        default:
            return ""
        }
    }
}
