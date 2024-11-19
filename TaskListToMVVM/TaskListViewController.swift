import UIKit

class TaskListViewController: UIViewController {
    private let viewModel = TaskListViewModel()
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTableView()
        
        // 載入今天的任務
        viewModel.loadTasks(for: Date())
    }
    
    private func setupUI() {
        title = "任務清單"
        view.backgroundColor = .systemBackground
        
        // 設置 TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 設置添加按鈕
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TaskCell")
    }
    
    private func setupBindings() {
        viewModel.onTasksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func addButtonTapped() {
        let alert = UIAlertController(title: "新增任務", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "任務標題"
        }
        
        let addAction = UIAlertAction(title: "新增", style: .default) { [weak self] _ in
            guard let title = alert.textFields?.first?.text, !title.isEmpty else { return }
            
            let newTask = Task(
                id: UUID(),
                title: title,
                description: nil,
                dueDate: Date(),
                status: .todo,
                priority: .medium,
                notificationEnabled: false
            )
            
            self?.viewModel.addTask(newTask)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(addAction)
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        let task = viewModel.tasks[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        content.secondaryText = "優先級: \(task.priority.rawValue) | 狀態: \(task.status.rawValue)"
        cell.contentConfiguration = content
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TaskListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 可以在這裡添加點擊處理邏輯
    }
}



////
////  ViewController.swift
////  TaskListToMVVM
////
////  Created by Lydia Lu on 2024/11/18.
////
//
//import UIKit
//
//class TaskListViewController: UIViewController {
//    private let viewModel = TaskListViewModel()
//    private let tableView = UITableView()
//    
//    private func setupBindings() {
//        // 數據綁定
//        viewModel.onTasksUpdated = { [weak self] in
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
//        }
//    }
//}
