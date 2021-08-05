//
//  Bank.swift
//  BankManagerConsoleApp
//
//  Created by JINHONG AN on 2021/07/30.
//

import Foundation

class Bank {
    private var numberOfBankTellers: Int = .zero
    private var bankTellerQueue = Queue<BankTeller>()
    private var customerQueue = Queue<Customer>()
    private var totalNumberOfVisitors: UInt = .zero
    
    func close() {
        numberOfBankTellers = .zero
        bankTellerQueue.clear()
        customerQueue.clear()
        totalNumberOfVisitors = .zero
    }
    
    func takeNumberTicket() -> UInt {
        totalNumberOfVisitors += 1
        return totalNumberOfVisitors
    }
    
    func hire(employees: [BankTeller]) {
        numberOfBankTellers = employees.count
        employees.forEach { bankTellerQueue.enqueue($0) }
    }
    
    func receive(customers: [Customer]) {
        customers.forEach { customerQueue.enqueue($0) }
    }
    
    func serveCustomers() {
        let semaphore = DispatchSemaphore(value: numberOfBankTellers)
        let group = DispatchGroup()
        while let currentCustomer = customerQueue.dequeue() {
            semaphore.wait()
            guard let bankTeller = bankTellerQueue.dequeue() else {
                customerQueue.enqueue(currentCustomer)
                semaphore.signal()
                continue
            }
            group.enter()
            DispatchQueue.global().async {
                bankTeller.serve(customer: currentCustomer)
                self.bankTellerQueue.enqueue(bankTeller)
                semaphore.signal()
                group.leave()
            }
        }
        group.wait()
    }
}