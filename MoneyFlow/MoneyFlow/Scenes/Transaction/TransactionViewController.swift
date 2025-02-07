//
//  TransactionViewController.swift
//  MoneyFlow
//
//  Created by Brian Nahuel Borromeo Da Costa on 3/09/24.
//

import UIKit
import RealmSwift

protocol TransactionView: AnyObject {
    
}

final class TransactionViewController: UIViewController {
    var presenter: TransactionPresenterProtocol!
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .customColorPrimary)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "Monto:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ingrese el monto"
        textField.borderStyle = .roundedRect
        textField.textColor = UIColor(named: "CustomPrimaryColor")
        textField.backgroundColor = .white
        textField.keyboardType = .decimalPad
        textField.tag = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .customColorPrimary)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "Detalle:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailTextfield: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Ingrese un detalle"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.textColor = UIColor(named: "CustomPrimaryColor")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let transactionTypeSegmentedControl: UISegmentedControl = {
        let items = [TransactionType.expense.rawValue, TransactionType.income.rawValue]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = UIColor(resource: .customColorExpense)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Selecciona la categoría"
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.cornerRadius = 10.0
        textField.layer.borderWidth = 2.0
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.tintColor = .clear
        textField.tag = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoryPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    private let toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()
    
    private let doneButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        barButtonItem.title = "Listo"
        barButtonItem.style = .plain
        barButtonItem.action = #selector(dismissKeyboard)
        return barButtonItem
    }()
    
    private let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(resource: .customColorPrimary)
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.text = "Selecciona la fecha:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        return datePicker
    }()
    
    private let registerTransactionButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Registrar Transacción"
        configuration.baseBackgroundColor = UIColor(resource: .customColorIncome)
        button.configuration = configuration
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        amountTextField.becomeFirstResponder()
        
        toolBar.setItems([flexibleSpace,doneButton], animated: false)
        amountTextField.inputAccessoryView = toolBar
        detailTextfield.inputAccessoryView = toolBar
        categoryTextField.inputAccessoryView = toolBar
        
        view.backgroundColor = .white
        title = "Nueva Transacción"
        
        amountTextField.delegate = self
        categoryTextField.delegate = self
        categoryPickerView.dataSource = self
        categoryPickerView.delegate = self
        
        categoryTextField.inputView = categoryPickerView
        
        transactionTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        registerTransactionButton.addTarget(self, action: #selector(didTapRegisterTransactionButton), for: .touchUpInside)
        
        [amountLabel,amountTextField, detailLabel, detailTextfield, categoryTextField, transactionTypeSegmentedControl, dateLabel, datePicker, registerTransactionButton].forEach(view.addSubview)
        
        NSLayoutConstraint.activate([
            amountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            amountLabel.widthAnchor.constraint(equalToConstant: 70),
            amountLabel.heightAnchor.constraint(equalTo: amountTextField.heightAnchor, multiplier: 1),
            
            amountTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            amountTextField.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 20),
            amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            detailLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 20),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            detailLabel.widthAnchor.constraint(equalToConstant: 70),
            detailLabel.heightAnchor.constraint(equalTo: detailTextfield.heightAnchor, multiplier: 1),
            
            detailTextfield.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            detailTextfield.leadingAnchor.constraint(equalTo: detailLabel.trailingAnchor, constant: 20),
            detailTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            transactionTypeSegmentedControl.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 20),
            transactionTypeSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            transactionTypeSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            categoryTextField.topAnchor.constraint(equalTo: transactionTypeSegmentedControl.bottomAnchor, constant: 20),
            categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            categoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            dateLabel.widthAnchor.constraint(equalToConstant: 150),
            dateLabel.heightAnchor.constraint(equalTo: datePicker.heightAnchor, multiplier: 1),
            
            datePicker.topAnchor.constraint(equalTo: categoryTextField.bottomAnchor, constant: 20),
            datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            registerTransactionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            registerTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        transactionTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black ], for: .normal)
        transactionTypeSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            transactionTypeSegmentedControl.selectedSegmentTintColor = UIColor(resource: .customColorExpense)
            showCategoryTextField()
            presenter.transactionType = .expense
        case 1:
            transactionTypeSegmentedControl.selectedSegmentTintColor = UIColor(resource: .customColorIncome)
            hideCategoryTextField()
            presenter.transactionType = .income
            categoryTextField.text = .none
            categoryPickerView.selectRow(0, inComponent: 0, animated: false)
        default:
            break
        }
    }
    
    @objc private func didTapRegisterTransactionButton() {
        var isComplete: Bool
        guard let amount = Double(amountTextField.text!) else { return }
        let detail = detailTextfield.text ?? ""
        let category = categoryTextField.text ?? ""
        
        isComplete = presenter.recordTransaction(amount: amount, detail: detail, category: category, date: datePicker.date)
        print(isComplete)
    }
    
    private func showCategoryTextField() {
        categoryTextField.isHidden = false
    }
    
    private func hideCategoryTextField() {
        categoryTextField.resignFirstResponder()
        categoryTextField.isHidden = true
    }
}

extension TransactionViewController: UITextFieldDelegate {
    
    // TODO: - Fix a error when the user change from another textField to the amountTextfield(Can write a letter)
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            let currentText = textField.text ?? ""
            
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
            
            if updatedText.isEmpty {
                return true
            }
            
            let decimalSeparator = Locale.current.decimalSeparator ?? "."
            
            if string == decimalSeparator && currentText.contains(decimalSeparator) {
                return false
            }
            
            let regex = "^[0-9]*\(decimalSeparator)?[0-9]*$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            
            return predicate.evaluate(with: updatedText)
        } else if textField.tag == 2 {
            return false
        }
        return true
    }
}

extension TransactionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        presenter.categoriesCount
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return presenter.getTitleForRow(row: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryTextField.text = presenter.getTitleForRow(row: row)
    }
    
}

extension TransactionViewController: TransactionView {
    
}
