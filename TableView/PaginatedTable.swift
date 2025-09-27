//
//  PaginatedTable.swift
//  TableView
//
//  Created by MacBook on 23/09/25.
//

import Cocoa

class PaginatedTable: NSTableView {
    private var topBorderRows: [Int] = []
    private var bottomBorderRows: [Int] = []

    // Taken from here: http://lists.apple.com/archives/cocoa-dev/2002/Nov/msg01710.html
    // Ensures rows in the table aren't cut off when printing
    override func adjustPageHeightNew(
        _ newBottom: UnsafeMutablePointer<CGFloat>,
        top oldTop: CGFloat,
        bottom oldBottom: CGFloat,
        limit bottomLimit: CGFloat
    ) {

        // This method gets called repeatedly for each page break.
        // Reset the arrays at the beginning of the print job
        // to avoid incorrect borders on subsequent prints.
        if topBorderRows.isEmpty && bottomBorderRows.isEmpty {
            topBorderRows = []
            bottomBorderRows = []
        }

        let cutoffRow = self.row(at: NSPoint(x: 0, y: oldBottom))
        var rowBounds: NSRect

        newBottom.pointee = oldBottom
        if cutoffRow != -1 {
            rowBounds = self.rect(ofRow: cutoffRow)
            if oldBottom < NSMaxY(rowBounds) {
                newBottom.pointee = NSMinY(rowBounds)

                let previousRow = cutoffRow - 1

                // Mark which rows need which border, ignore ones we've already seen, and adjust ones that need different borders
                if topBorderRows.last != cutoffRow {
                    if bottomBorderRows.last == cutoffRow {
                        topBorderRows.removeLast()
                        bottomBorderRows.removeLast()
                    }

                    topBorderRows.append(cutoffRow)
                    bottomBorderRows.append(previousRow)
                }
            }
        }
    }

    // Draw the row as normal, and add any borders to cells that were pushed down due to pagination
    override func drawRow(_ rowIndex: Int, clipRect: NSRect) {
        super.drawRow(rowIndex, clipRect: clipRect)

        if topBorderRows.isEmpty {
            return
        }

        let rowRect = self.rect(ofRow: rowIndex)
        let gridPath = NSBezierPath()
        let color = NSColor.gridColor

        for i in 0..<topBorderRows.count {
            let rowNeedingTopBorder = topBorderRows[i]
            if rowNeedingTopBorder == rowIndex {
                gridPath.move(to: rowRect.origin)
                gridPath.line(to: NSPoint(x: rowRect.origin.x + rowRect.size.width, y: rowRect.origin.y))

                color.setStroke()
                gridPath.stroke()
            }

            let rowNeedingBottomBorder = bottomBorderRows[i]
            if rowNeedingBottomBorder == rowIndex {
                gridPath.move(to: NSPoint(x: rowRect.origin.x, y: rowRect.origin.y + rowRect.size.height))
                gridPath.line(to: NSPoint(x: rowRect.origin.x + rowRect.size.width, y: rowRect.origin.y + rowRect.size.height))

                color.setStroke()
                gridPath.stroke()
            }
        }
    }
}
