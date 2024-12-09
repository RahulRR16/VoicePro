//
//  TableViewSupport.swift
//  Metals
//
//  Created by Rahul on 11/06/24.
//

import UIKit

// Make UITableViewCell, conforming to ReusableView Protocol, in order to have the "out of the box" reuse identifier
extension UITableViewCell: ReusableView {}

extension UITableView {

    /// Use this method, in order not to cast TableViewCells.
    /// Important: Explicit type needs to be added. Reuse identifier in storyboards needs to match the name of the cell class
    /// Example: let cell: LockCardTableViewCell = tableView.dequeueReusableCell(for: indexPath)
    /// - Parameter indexPath: The index path specifying the location of the cell.
    /// - Returns: Returns a reusable table-view cell object, without the need to cast it
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue reusable table view cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }

    /// Register array of UITableViewCells at once
    /// - Parameter cells: array of UITableViewCells
    func registerCells(_ cells: [UITableViewCell.Type]) {
        cells.forEach {
            register($0, forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }

}

protocol ReusableView {

    /// Identifier matching the name of the class
    static var reuseIdentifier: String { get }
    static var nib: UINib { get }
}

extension ReusableView {

    /// Identifier matching the name of the class
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

}
