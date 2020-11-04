report 50000 "Purchase Order Customs"
{
    CaptionML = ENU = 'Purchase Order Customs', RUS = 'Таможенный заказ покупки';
    DefaultLayout = RDLC;
    RDLCLayout = 'Purchase Order Customs.rdl';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    AccessByPermission = report "Purchase Order Customs" = x;

    dataset
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            RequestFilterFields = "No.", "Buy-from Vendor No.";
            DataItemTableView = where("Document Type" = Const(Order));

            column(VendorName; "Buy-from Vendor Name" + "Buy-from Vendor Name 2") { }
            column(VendorAdress; "Buy-from Address" + "Buy-from Address 2") { }
            column(VendorCity; "Buy-from City" + ', ' + "Buy-from Country/Region Code") { }
            column(CompanyName; "Ship-to Name" + "Ship-to Name 2") { }
            column(CompanyAdress; "Ship-to Address" + "Ship-to Address 2") { }
            column(CompanyCity; "Ship-to City" + ', ' + "Ship-to County" + ' ' + "Ship-to Post Code") { }
            column(InvoiceNo; "Vendor Invoice No.") { }
            column(InvoiceDate; CaptionMgt.FormatDateUS("Order Date")) { }
            column(InvoiceTotal; PurchaseHeader."Amount Including VAT") { }
            dataitem(PurchaseLine; "Purchase Line")
            {
                DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
                DataItemLink = "Document Type" = field("Document Type"), "Document No." = field("No.");

                column(PositionNo; PositionNo) { }
                column(Description; Description) { }
                column(Quantity; Quantity)
                {
                    DecimalPlaces = 0 : 0;
                }
                column(DirectUnitCost; "Direct Unit Cost")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(AmountIncludingVAT; "Amount Including VAT")
                {
                    DecimalPlaces = 2 : 2;
                }
                column(GrossWeight; "Gross Weight")
                {
                    DecimalPlaces = 0 : 0;
                }
                column(FDA_Value; CaptionMgt.GetItemAttributeValue(FDA_Label, "No.")) { }
                column(HTS_Value; CaptionMgt.GetItemAttributeValue(HTS_Label, "No.")) { }

                trigger OnAfterGetRecord()
                begin
                    PositionNo += 1;
                end;

            }

            trigger OnAfterGetRecord();
            begin
                PositionNo := 0;
            end;


        }

    }

    requestpage
    {
        SaveValues = true;
        layout { }
        actions { }
    }

    labels { }

    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin

    end;

    var
        totalPurchLine: Record "Purchase Line";
        CaptionMgt: Codeunit "Caption Mgt.";
        PositionNo: Integer;
        totalAmountIncVat: Decimal;
        FDA_Label: Label 'FDA Code';
        HTS_Label: Label 'HTS Code';
}