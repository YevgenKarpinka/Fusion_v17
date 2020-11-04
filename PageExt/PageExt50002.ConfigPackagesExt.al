pageextension 50002 "Config. Packages Ext." extends "Config. Package Subform"
{
    layout
    {
    }
    actions
    {
        // Add changes to page actions here
        addafter(ImportFromExcel)
        {
            // action(ExportBigDataExcel)
            // {
            //     ApplicationArea = All;
            //     Caption = 'Export Item Descr. to Excel';
            //     Image = ExportToExcel;

            //     trigger OnAction()
            //     begin
            //         ExportBigDataExcel;
            //     end;
            // }
            action(ImportBigDataExcel)
            {
                ApplicationArea = All;
                Caption = 'Import Item Descr. from Excel';
                Image = ImportExcel;

                trigger OnAction()
                begin
                    ImportBigDataExcel;
                end;
            }
            action(Export2JSON)
            {
                ApplicationArea = All;
                Caption = 'Export2JSON';
                Image = ExchProdBOMItem;

                trigger OnAction()
                begin
                    // Export2JSON;
                end;
            }
        }
    }

    procedure ImportBigDataExcel()
    var
        ItemDescrManagement: Codeunit "Item Descr. Management";
    begin
        ItemDescrManagement.ImportExcelSheet;
    end;

    procedure Export2JSON()
    var
        ConfigPackageTable: Record "Config. Package Table";
        ItemDescrManagement: Codeunit "Item Descr. Management";
    begin
        CurrPage.SetSelectionFilter(ConfigPackageTable);
        ItemDescrManagement.Export2JSON(ConfigPackageTable);
    end;

    var
        MultipleTablesSelectedQst: TextConst ENU = '%1 tables have been selected. Do you want to continue?';
        SingleTableSelectedQst: TextConst ENU = 'One table has been selected. Do you want to continue?';
}
