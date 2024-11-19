import UIKit

class TaskListViewController: UIViewController {
    private let viewModel = TaskListViewModel()
    private let tableView = UITableView()
    private var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupTableView()
        viewModel.loadTasks(for: Date())
    }
    
    private func setupUI() {
        title = "任務清單"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
        showAddTaskAlert()
    }
    
    private func showAddTaskAlert() {
        alert = UIAlertController(title: "新增任務", message: nil, preferredStyle: .alert)
        
        // 標題輸入
        alert?.addTextField { textField in
            textField.placeholder = "任務標題"
        }
        
        // 優先級選擇 - 使用選擇器
        alert?.addTextField { textField in
            textField.text = "中"
        }
        let priorityPicker = UIPickerView()
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        priorityPicker.tag = 0
        alert?.textFields?[1].inputView = priorityPicker
        
        // 狀態選擇 - 使用選擇器
        alert?.addTextField { textField in
            textField.text = "待辦"
        }
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusPicker.tag = 1
        alert?.textFields?[2].inputView = statusPicker
        
        let addAction = UIAlertAction(title: "新增", style: .default) { [weak self] _ in
            guard let title = self?.alert?.textFields?[0].text, !title.isEmpty,
                  let priorityText = self?.alert?.textFields?[1].text,
                  let statusText = self?.alert?.textFields?[2].text,
                  let priority = TaskPriority(rawValue: priorityText),
                  let status = TaskStatus(rawValue: statusText) else { return }
            
            let newTask = Task(
                id: UUID(),
                title: title,
                description: nil,
                dueDate: Date(),
                status: status,
                priority: priority,
                notificationEnabled: false
            )
            
            self?.viewModel.addTask(newTask)
        }
        
        alert?.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert?.addAction(addAction)
        
        present(alert!, animated: true)
    }
    
    private func showEditAlert(for indexPath: IndexPath) {
        let task = viewModel.tasks[indexPath.row]
        alert = UIAlertController(title: "編輯任務", message: nil, preferredStyle: .alert)
        
        // 標題輸入
        alert?.addTextField { textField in
            textField.text = task.title
            textField.placeholder = "任務標題"
        }
        
        // 優先級選擇 - 使用選擇器
        alert?.addTextField { textField in
            textField.text = task.priority.rawValue
        }
        let priorityPicker = UIPickerView()
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        priorityPicker.tag = 0
        alert?.textFields?[1].inputView = priorityPicker
        
        // 狀態選擇 - 使用選擇器
        alert?.addTextField { textField in
            textField.text = task.status.rawValue
        }
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        statusPicker.tag = 1
        alert?.textFields?[2].inputView = statusPicker
        
        let saveAction = UIAlertAction(title: "儲存", style: .default) { [weak self] _ in
            guard let title = self?.alert?.textFields?[0].text,
                  let priorityText = self?.alert?.textFields?[1].text,
                  let statusText = self?.alert?.textFields?[2].text,
                  let priority = TaskPriority(rawValue: priorityText),
                  let status = TaskStatus(rawValue: statusText)
            else { return }
            
            var updatedTask = task
            updatedTask.title = title
            updatedTask.priority = priority
            updatedTask.status = status
            
            self?.viewModel.updateTask(updatedTask, at: indexPath.row)
        }
        
        alert?.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert?.addAction(saveAction)
        
        present(alert!, animated: true)
    }
    
}

// MARK: - UITableViewDataSource & Delegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showEditAlert(for: indexPath)
    }
    

}

extension TaskListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 { // Priority picker
            return ["低", "中", "高"].count
        } else { // Status picker
            return ["待辦", "進行中", "完成"].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return ["低", "中", "高"][row]
        } else {
            return ["待辦", "進行中", "完成"][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            alert?.textFields?[1].text = ["低", "中", "高"][row]
        } else {
            alert?.textFields?[2].text = ["待辦", "進行中", "完成"][row]
        }
    }
}




