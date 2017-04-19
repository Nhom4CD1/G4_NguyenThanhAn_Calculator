//
//  ViewController.swift
//  Calculator
//
//  Created by THANH on 4/18/17.
//  Copyright © 2017 THANH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //Định dạng(kiểu mẫu) của toán hạng nhập vào
    let numberPattern : String = "[-]?(\\d*)(\\.(\\d*))?"
    // Kiểm tra trạng thái nút nhấn là Toán hạng hay toán tử
    @IBOutlet weak var btnReset: UIButton!
    var isToanHangClick : Bool = false;
    var isToanTuClick : Bool = false;
    
    @IBOutlet weak var lbToanHang: UILabel!
    @IBOutlet weak var lbKQ: UILabel!
    //@IBOutlet weak var lbToanHang: UILabel!
    //@IBOutlet weak var lbKQ: UILabel!
    
    
    var holder_btnToanTu : UIButton? = nil
    
    var holdAction  : enumPHEPTOAN = enumPHEPTOAN.NONE;
    var olderAction : enumPHEPTOAN = enumPHEPTOAN.NONE;
    //Khai báo hai biến giữ các toán hạng(các số truyền vào)
    var ToanHangA : Double = 0
    var ToanHangB : Double = 0
    var chooseToanHangA : Bool = true
    var zeroflag : Bool = false;
    
    enum enumPHEPTOAN {
        case NONE
        case PHEPNHAN
        case PHEPCHIA
        case PHEPCONG
        case PHEPTRU
        case TINHTOAN
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.btn_Reset_onClick()
        //self.btn_Reset_onClick (self)
       // self.btn_Reset_onClick(btnReset)
    }
    //1. Hàm thực thi khi nhấn button Reset(AC)
    @IBAction func btn_Reset_onClick(_ sender: UIButton) {
        
        btn_TruyenButton(sender) ;
        lbToanHang.text = "" ;
        lbKQ.text = "" ;
        zeroflag = false;
        
        ToanHangA = 0;
        ToanHangB = 0;
        
        isToanHangClick = false ;
        isToanTuClick = false ;
        
        chooseToanHangA = true;
        //Nếu chưa chọn toán tử(+,-,*,/)
        holdAction = enumPHEPTOAN.NONE;
        if holder_btnToanTu != nil {
            btn_ResetBoder(holder_btnToanTu!)
        }
    }
    
    //2.Hàm thực thi khi nhấn button toán tử  PHEPNHAN, PHEPCHIA, PHEPCONG.... action click
    @IBAction func btnToanTu_onClick(_ sender: UIButton) {
        
        //set animation truyền đối tượng là button
        btn_TruyenButton(sender);
        //Xoá button đã clicked trước đó
        if holder_btnToanTu != nil {
            
            btn_ResetBoder(holder_btnToanTu!)
        }
        //  button hiện tại đang được clicked
        holder_btnToanTu = sender
        // set border for button clicked
        BtnHoldingBorder(sender);
        // hold older action
        olderAction = holdAction
        // Nhận giá trị từ lbToanHang
        let s : String = lbToanHang.text == "" ? "0.0" : lbToanHang.text!
        // Đưa số vào operandB
        chooseToanHangA ? ( ToanHangA = Double(s)! ) : ( ToanHangB = Double(s)! )
        // Trong lần đầu chạy, sẽ gán số cho A
        chooseToanHangA = false;
        //Mỗi button đã được gắn tag riêng biệt để phân biệt khi gọi
        switch sender.tag {
            
        case 10:
            holdAction = enumPHEPTOAN.PHEPCONG;
            
        case 11:
            holdAction = enumPHEPTOAN.PHEPTRU;
            
        case 12:
            holdAction = enumPHEPTOAN.PHEPNHAN;
            
        case 13:
            holdAction = enumPHEPTOAN.PHEPCHIA;
            
        default:
            // action equal clicked
            btn_ResetBoder(sender)
            CalculatingAction(holdAction)
            //update status for keyboard
            isToanHangClick = false;
            isToanTuClick = true;
            return
        }
        
        //same operator can quickly calculating
        if(isToanHangClick && OperatorPriority(olderAction) == OperatorPriority(holdAction)){
            CalculatingAction(olderAction)
        }
        //cập nhật trạng thái bàn phím
        isToanHangClick = false;
        isToanTuClick = true;
    }
    
    //3. Xử lí khi nhấn phím là toán hạng (số, dấu .,dấu -)
    @IBAction func btn_ToanHang_onClick(_ sender: UIButton) {
        
        btn_TruyenButton(sender);
        // check correct number
        var validNumber : Bool = false;
        if isToanTuClick {
            lbToanHang.text = ""
        }
        //get number from lbToanHang
        var text = lbToanHang.text!
        var value : String = "";
        //Các button đặc biệt đã được gắn tag để phân biệt
        switch sender.tag {
        case 23:
            value = String("."); //dấu châm thập phân
            break;
            
        case 21:
            value = String("-"); //Dấu - cho số âm
            break;
            
        case 22:
            // Nếu là dấu %
            if(text == "") {
                
                text = "0.0"
            }
            let number = Double(text)! / 100 * 1.0;
            lbToanHang.text = String(number)
            sender.tag = ~(-3) + 1 //  two's complement
            return
            
        case ~(22) + 1:
            if(text == "") {
                
                text = "0.0"
            }
            let number = Double(text)! * 100 * 1.0;
            lbToanHang.text = String(number)
            sender.tag = -3 //  two's complement
            break;
            
        default:
            value = String(sender.tag);
            break;
        }
        validNumber = isvalidNumber(sNumber: (text + value), numberPattern: numberPattern)
        if(validNumber){
            
            lbToanHang.text! += value;
        }
        else{
            
            alert(message: "Số không hợp lệ!", title: "Error Number")
        }
        
        //update status for keyboard
        isToanHangClick = true;
        isToanTuClick = false;
        //        isDeleteClick = false;
    }
    
    // 4 Hàm trả về giá trị cho operandA và đưa KQ ra màn hình
    func CalculatingAction(_ action : enumPHEPTOAN){
        ToanHangA = CalculatingNumber(action, a: ToanHangA, b: ToanHangB)
        if(zeroflag) {
            //gọi hàm Reset
          self.btn_Reset_onClick(btnReset)
            lbKQ.text = ""
        }
        else { lbKQ.text = String(ToanHangA) }
    }
    
    //5. Hàm tính toán giữa hai toán hạng (hai số) double number
    func CalculatingNumber(_ action : enumPHEPTOAN, a : Double, b : Double) -> Double {
        
        switch action {
            
        case enumPHEPTOAN.PHEPNHAN:
            return a * b
            
        case enumPHEPTOAN.PHEPCHIA:
            if(b==0) {
                zeroflag = true// phất cờ chia 0
                alert(message: "Không thể chia cho 0!", title: "Div Zero")
                return 0
            }
            else { return (a / b) }
            
        case enumPHEPTOAN.PHEPCONG:
            return a + b
            
        case enumPHEPTOAN.PHEPTRU:
            return a - b
            
        default:
            if(chooseToanHangA){
                
                return a
            }
            else {
                
                return b
            }
        }
    }
    
    //6. func get priority of operator
    private func OperatorPriority(_ myOperator : enumPHEPTOAN) -> Int {
        
        switch myOperator {
            
        case enumPHEPTOAN.PHEPNHAN, enumPHEPTOAN.PHEPCHIA:
            return 10
            
        case enumPHEPTOAN.PHEPCONG, enumPHEPTOAN.PHEPTRU:
            return 5
            
        default:
            return 0
        }
    }
    
    //7. func clear border
    private func btn_ResetBoder(_ sender : UIButton) -> Void {
        sender.layer.borderWidth = 0.0
        sender.layer.borderColor = sender.layer.backgroundColor
    }
    
    //8. func perform simple border
    private func BtnHoldingBorder(_ sender : UIButton) -> Void {
        
        sender.layer.borderWidth = 2.0
        sender.layer.borderColor =
            UIColor(red : 0 / 255.0, green : 0 / 255.0, blue : 255.0 / 255.0, alpha : 1.0).cgColor
    }
    
    //9. Hàm lấy thông tin và truyền đối tượng sender button transform sau khi click
    private func btn_TruyenButton (_ sender : UIButton) -> Void {
        
        var rotationAndPerspectiveTransform : CATransform3D = CATransform3DIdentity;
        rotationAndPerspectiveTransform.m34 = 1.0 / -500;
        rotationAndPerspectiveTransform = CATransform3DMakeTranslation(3.0, 3.0, 1.0)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            
            sender.layer.transform = rotationAndPerspectiveTransform;
        }) { (success) in
            if success {
                
                sender.transform = CGAffineTransform.identity
            }
        }
    }
    
    //10. Kiểm tra số hợp lệ với đúng mẫu (định dạng) sau: "[-]?(\\d*)(\\.(\\d*))?"
    func isvalidNumber( sNumber : String, numberPattern : String) -> Bool {
        
        let regex = NSPredicate(format:"SELF MATCHES %@", numberPattern);
        return regex.evaluate(with: sNumber)
    }
    
    //11. Hiện Thông báo tới người dùng
    func alert(message: String, title: String = "") {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }}

