report 50002 "Sales Order Fusion"
{
    CaptionML = ENU = 'Sales Order Fusion', RUS = 'Заказ продажи Fusion';
    DefaultLayout = RDLC;
    RDLCLayout = 'Sales Order Fusion.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    AccessByPermission = report "Sales Order Fusion" = x;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            RequestFilterFields = "No.", "Sell-to Customer No.";
            DataItemTableView = where("Document Type" = Const(Order));

            column(CompanyName; CompanyInfo.Name + CompanyInfo."Name 2") { }
            column(CompanyAdress; CompanyInfo.Address + CompanyInfo."Address 2") { }
            column(CompanyCity; CompanyInfo.City + ', ' + CompanyInfo.County + ' ' + CompanyInfo."Post Code") { }
            column(CompanyPhone; 'phone ' + CompanyInfo."Phone No.") { }
            column(CompanyFax; 'fax ' + CompanyInfo."Phone No. 2") { }
            column(Bill_to_Name; "Sell-to Customer Name" + "Sell-to Customer Name 2") { }
            column(Bill_to_Address; "Sell-to Address" + "Sell-to Address 2") { }
            column(Bill_to_City; "Sell-to City" + ' ' + "Sell-to County" + ' ' + "Sell-to Post Code") { }
            column(Order_Date; CaptionMgt.FormatDateUS("Order Date")) { }
            column(OrderNo; "No.") { }
            column(TotalAmount; "Amount Including VAT")
            {
                DecimalPlaces = 2 : 2;
            }
            dataitem(SaleLine; "Sales Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                DataItemLink = "Document No." = field("No.");

                column(Quantity; Quantity)
                {
                    DecimalPlaces = 0 : 0;
                }
                column(Description; Description) { }
                column(Unit_Price; "Unit Price")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(AmountIncludingVAT; "Amount Including VAT")
                {
                    DecimalPlaces = 2 : 2;
                }

                trigger OnAfterGetRecord()
                begin
                end;

            }
        }
    }

    requestpage
    {
        layout { }
        actions { }
    }

    trigger OnInitReport()
    begin
        CompanyInfo.Get();
    end;

    trigger OnPreReport()
    begin

    end;

    var
        CompanyInfo: Record "Company Information";
        CaptionMgt: Codeunit "Caption Mgt.";
}