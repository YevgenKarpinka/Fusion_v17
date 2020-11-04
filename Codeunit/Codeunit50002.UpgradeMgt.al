codeunit 50002 "Upgrade Mgt."
{
    Subtype = Upgrade;
    Permissions = tabledata "NAV App Setting" = rimd;

    trigger OnRun()
    begin

    end;

    trigger OnUpgradePerCompany()
    begin
        EnableWebServiseCalls();
    end;

    procedure EnableWebServiseCalls()
    var
        NAVAppSettings: Record "NAV App Setting";
        TenantMgt: Codeunit "Environment Information";
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        // if TenantMgt.IsSandbox() then begin
        NAVAppSettings."App ID" := AppInfo.Id;
        NAVAppSettings."Allow HttpClient Requests" := true;
        if not NAVAppSettings.Insert() then NAVAppSettings.Modify();
        // end;
    end;
}