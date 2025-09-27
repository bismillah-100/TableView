//
//  ViewController.swift
//  TableView
//
//  Created by MacBook on 23/09/25.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var tableView: NSTableView!

    var data = [[String]]()

    @IBOutlet var tablePrint: NSTableView!
    func tableView(_ tableView: NSTableView,
                   setObjectValue object: Any?,
                   for tableColumn: NSTableColumn?,
                   row: Int) {
        guard let identifier = tableColumn?.identifier.rawValue else { return }

        if identifier == "Kolom1", let newValue = object as? String {
            data[row][0] = newValue
        } else if identifier == "Kolom2", let newValue = object as? String {
            data[row][1] = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tablePrint.delegate = self
        tablePrint.dataSource = self
        tableView.allowsColumnReordering = false
        tableView.allowsColumnResizing = true
        tableView.allowsMultipleSelection = false
        tableView.allowsEmptySelection = true

        // Membuat 10 data acak
        for i in 1...88 {
            let rowData = [
                "Data Kolom 1 Baris \(i) - Acak \(Int.random(in: 100...999))",
                "Data Kolom 2 Baris \(i) - Acak \(Int.random(in: 100...999))"
            ]
            data.append(rowData)
        }

        // Mengatur data source dan delegate
        tableView.dataSource = self
        tableView.delegate = self

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let columnIdentifier = tableColumn?.identifier.rawValue else { return nil }
        let rowData = data[row]
        // Asumsikan identifier kolom adalah "Kolom1" dan "Kolom2"
        if columnIdentifier == "Kolom1" {
            return rowData[0]
        } else if columnIdentifier == "Kolom2" {
            return rowData[1]
        }
        return nil
    }

    @IBAction func printTableViewWithSpecificWidth(_ sender: Any) {
        // 1. Buat tabel khusus untuk printing dengan konfigurasi yang tepat
        let printingTableView = PaginatedTable()

        // Copy kolom dari tabel utama
        for column in tableView.tableColumns {
            let newColumn = NSTableColumn(identifier: column.identifier)
            newColumn.title = column.title
            newColumn.width = column.width
            printingTableView.addTableColumn(newColumn)
        }

        // Set delegate dan dataSource
        printingTableView.delegate = self
        printingTableView.dataSource = self

        // KONFIGURASI PENTING: Atur grid lines untuk printing
        printingTableView.gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        printingTableView.backgroundColor = NSColor.white
        printingTableView.intercellSpacing = NSSize(width: 0, height: 1) // Penting untuk grid lines

        // Reload data
        printingTableView.reloadData()

        // 2. Hitung ukuran yang tepat
        let rowHeight: CGFloat = printingTableView.rowHeight
        let headerHeight: CGFloat = 24 // Standard header height
        let totalHeight = headerHeight + (rowHeight * CGFloat(data.count))
        let tableWidth: CGFloat = 972.0

        // 3. Buat container view dengan ukuran tepat
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: tableWidth, height: totalHeight))

        // 4. Atur frame tabel di dalam container
        printingTableView.frame = NSRect(x: 0, y: 0, width: tableWidth, height: totalHeight)
        containerView.addSubview(printingTableView)

        // 5. Buat stack view untuk layout
        let stackView = NSStackView(frame: NSRect(x: 0, y: 0, width: tableWidth, height: totalHeight + 60))
        stackView.orientation = .vertical
        stackView.spacing = 16.0
        stackView.alignment = .leading

        // Tambahkan judul
        let titleLabel = NSTextField(labelWithString: "Laporan Data Tabel")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 24)
        titleLabel.alignment = .left
        stackView.addArrangedSubview(titleLabel)

        // Tambahkan container view (berisi tabel)
        stackView.addArrangedSubview(containerView)

        stackView.layoutSubtreeIfNeeded()

        // 6. Setup print info dengan pagination yang benar
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 0
        printInfo.bottomMargin = 0
        printInfo.leftMargin = 0
        printInfo.rightMargin = 0
        printInfo.orientation = .landscape

        // KONFIGURASI PAGINATION YANG TEPAT:
        printInfo.verticalPagination = .automatic    // Bagi secara vertikal ke multiple pages
        printInfo.horizontalPagination = .fit        // Fit to page width, no clipping

        // 7. Pastikan tabel di-render dengan benar sebelum printing
        printingTableView.display() // Force redraw

        // 8. Print operation
        let printOperation = NSPrintOperation(view: stackView, printInfo: printInfo)
        printOperation.printPanel.options = [.showsPaperSize, .showsOrientation]

        if let mainWindow = NSApplication.shared.mainWindow {
            printOperation.runModal(for: mainWindow, delegate: nil, didRun: nil, contextInfo: nil)
        }
    }
}

