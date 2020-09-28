//
//  ViewController.swift
//  sismos
//
//  Created by Familia Juarez Martinez on 9/25/20.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: PROPERTYS
    @IBOutlet weak var lblSlider: UILabel!
    @IBOutlet weak var sliderMag: UISlider!
    @IBOutlet weak var startDate: UITextField!
    @IBOutlet weak var endDate: UITextField!
    @IBOutlet weak var tbEartquakes: UITableView!

    var datePicker = UIDatePicker()
    let formater = DateFormatter()
    var strStartDate: String?
    var strEndDate: String?
    var floatMag: Float = 0.0

    var listOfEratQuakes = [Properties]() {
        didSet {
            DispatchQueue.main.async {
                self.tbEartquakes.reloadData()
            }
        }
    }

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createDatePickers()
        tbEartquakes.delegate = self
        tbEartquakes.dataSource = self
        formater.dateFormat = "YYYY-MM-dd"
    }
    
    // MARK: - ACTIONS METHODS
    @IBAction func sliderValue(_ sender: UISlider) {
        lblSlider.text = String(format: "%.1f", sender.value)
        floatMag = Float(lblSlider.text!)!
    }

    @IBAction func newSearchPressed(_ sender: Any) {
        if (self.startDate.text == "" || self.endDate.text == "" || lblSlider.text == "") {
            self.alert(message: "Selecciona la magnitud, una fecha de inicio y una fecha fin.")
        }
        else {
            strStartDate = self.startDate.text
            strEndDate = self.endDate.text
            let recordsRequest = Request(startTime: strStartDate!, endTime: strEndDate!, minMagnitude: floatMag)
            recordsRequest.getStations {[weak self] result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let records):
                    self?.listOfEratQuakes = records
                    if (self!.listOfEratQuakes.count > 0) {
                        self!.saveSearch()
                    }
                    else {
                        print("No se encontraron registros de sismos.")
                    }
                }
            }
        }
    }
        
    @IBAction func lastSearch(_ sender: Any) {
        floatMag = UserDefaults.standard.float(forKey: "Mag")
        strStartDate = UserDefaults.standard.string(forKey: "startDate")
        strEndDate = UserDefaults.standard.string(forKey: "endDate")
        
        let recordsRequest = Request(startTime: strStartDate!, endTime: strEndDate!, minMagnitude: floatMag)
        recordsRequest.getStations {[weak self] result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let records):
                self?.listOfEratQuakes = records
            }
        }
    }
    
    // MARK: - FUNCTIONS
    func saveSearch () {
        UserDefaults.standard.setValue(floatMag, forKey: "Mag")
        UserDefaults.standard.setValue(strStartDate, forKey: "startDate")
        UserDefaults.standard.setValue(strEndDate, forKey: "endDate")
    }

    func createDatePickers () { // Validar fecha inicio y fin
        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Seleccionar", style: .plain, target: nil, action: #selector(startDateSelected))
        toolBar.setItems([doneButton], animated: true)
        startDate.inputView = toolBar
        startDate.inputAccessoryView = datePicker

        let toolBar2 = UIToolbar()
        toolBar2.sizeToFit()

        let doneButton2 = UIBarButtonItem(title: "Seleccionar", style: .plain, target: nil, action: #selector(endDateSelected))
        toolBar2.setItems([doneButton2], animated: true)
        endDate.inputView = toolBar2
        endDate.inputAccessoryView = datePicker
    }
    
    
    @objc func startDateSelected () {
            startDate.text = formater.string(from: datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func endDateSelected () {
            endDate.text = formater.string(from: datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }

// MARK: - TABLEVIEW METHODS

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfEratQuakes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let record = listOfEratQuakes[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.textLabel!.text = record.properties.place
        cell.detailTextLabel?.text = "Magnitud: " + String(record.properties.mag!) + ", Hora: " + String(record.properties.time!) // Pendiente convertir Timestamp
        return cell
    }
}

// MARK: - EXTENSIONS

extension UIViewController {
  func alert(message: String, title: String = "") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(OKAction)
    self.present(alertController, animated: true, completion: nil)
  }
}
