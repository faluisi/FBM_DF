codeunit 61500 FBM_Migration_DF
{
    var
        comp: record Company;
        Termsconditions_old: record TermsConditions;
        Termsconditions_new: record FBM_TermsConditions;
        customer: record Customer;
        fbmcust: record FBM_Customer;
        site_old: record "Customer-Site";
        site_new: record FBM_Site;
        cos: record "Cust-Op-Site";
        cos_new: record FBM_CustOpSite;
        compinfo: record "Company Information";
        custLE: record "Cust. Ledger Entry";
        detCustLE: record "Detailed Cust. Ledg. Entry";
        fa: record "Fixed Asset";
        GenJnlLine: record "Gen. Journal Line";
        glaccount: record "G/L Account";
        glentry: record "G/L Entry";
        sheader: record "Sales Header";
        sline: record "Sales Line";

        siheader: record "Sales Invoice Header";
        siline: record "Sales Invoice Line";
        scheader: record "Sales Cr.Memo Header";
        scline: record "Sales Cr.Memo Line";
        salessetup: record "Sales & Receivables Setup";
        usetup: record "User Setup";
        vendorle: record "Vendor Ledger Entry";
        detvendorle: record "Detailed Vendor Ledg. Entry";
        vendor: record Vendor;
        bankacc: record "Bank Account";
        itemle: record "Item Ledger Entry";

    procedure dataMigration()
    begin
        if comp.FindFirst() then
            repeat
                Termsconditions_old.ChangeCompany(comp.Name);
                Termsconditions_new.ChangeCompany(comp.Name);

                if Termsconditions_old.FindFirst() then
                    repeat
                        Termsconditions_new.Init();
                        Termsconditions_new.Country := Termsconditions_old.Country;
                        Termsconditions_new."Line No." := Termsconditions_old."Line No.";
                        Termsconditions_new."Terms Conditions" := Termsconditions_old."Terms Conditions";
                        Termsconditions_new.Insert();
                    until Termsconditions_old.Next() = 0;
                customer.ChangeCompany(comp.Name);
                if customer.FindFirst() then
                    repeat
                        if not fbmcust.get(customer."No. 2") then begin
                            fbmcust.init;
                            fbmcust.TransferFields(customer, false);
                            fbmcust.Rename(customer."No. 2");
                            fbmcust.Modify();

                        end;
                        customer."FBM_Separate Halls Inv." := customer."Separate Halls Inv.";
                        customer."FBM_Customer Since" := customer."Customer Since";
                        customer.FBM_GrCode := customer."No. 2";
                    until customer.Next() = 0;
                cos.ChangeCompany(comp.Name);
                if cos.FindFirst() then
                    repeat
                        cos_new.Init();
                        cos_new."Customer No." := cos."Customer No.";
                        if customer.get(cos."Customer No.") then
                            cos_new."Operator No." := customer."No.";

                        cos_new."Site Code" := cos."Site Code 2";
                        cos_new.Insert();
                    until cos.Next() = 0;
                site_old.ChangeCompany(comp.Name);
                if site_old.FindFirst() then
                    repeat
                        cos.SetRange("Site Code", site_old."Site Code");
                        if cos.FindFirst() and not site_new.get(cos."Site Code 2") then begin
                            site_new.Init();
                            site_new."Site Code" := cos."Site Code 2";
                            site_new."Site Name" := site_old."Site Name";
                            site_new.Address := site_old.Address;
                            site_new."Address 2" := site_old."Address 2";
                            site_new.City := site_old.City;
                            site_new."Post Code" := site_old."Post Code";
                            site_new."Country/Region Code" := site_old."Country/Region Code";
                            site_new.Indent := site_old.Indent;
                            site_new."Contract Code" := site_old."Contract Code";
                            site_new."Vat Number" := cos."Vat Number";
                            site_new."Bank Filter" := site_old."Bank Filter";
                            site_new."Item Filter" := site_old."Item Filter";
                            site_new.Group := site_old.Group;
                            site_new.SubGroup := site_old.SubGroup;
                            site_new.Status := site_old.Status;
                            site_new."Current Status" := site_old."Current Status";
                            site_new.Category := site_old.Category;
                            site_new."Business Name" := site_old."Business Name";
                            site_new.Anniversary := site_old.Anniversary;
                            site_new."Cardinal Points" := site_old."Cardinal Points";
                            site_new."Area" := site_old."Area";
                            site_new.Region := site_old.Region;
                            site_new."Central Place" := site_old."Central Place";
                            site_new.Municipal := site_old.Municipal;
                            site_new.Insert()
                        end;
                    until site_old.Next() = 0;


                compinfo.ChangeCompany(comp.Name);
                if compinfo.FindFirst() then begin
                    compinfo."FBM_TIN Number" := compinfo."TIN Number";
                    compinfo.Modify();
                end;
                custLE.ChangeCompany(comp.Name);
                if custLE.FindFirst() then
                    repeat
                        custLE."FBM_Period End" := custLE."Period End";
                        custLE."FBM_Period Start" := custLE."Period Start";
                        custLE.Modify();
                    until custLE.Next() = 0;
                detcustLE.ChangeCompany(comp.Name);
                if detcustLE.FindFirst() then
                    repeat
                        detcustLE."FBM_Period End" := detcustLE."Period End";
                        detcustLE."FBM_Period Start" := detcustLE."Period Start";
                        detcustLE.Modify();
                    until detcustLE.Next() = 0;
                fa.ChangeCompany(comp.Name);
                if fa.FindFirst() then
                    repeat
                        fa."FBM_Date Prepared" := fa."Date Prepared";
                        fa."FBM_Fa Posting Group Depr" := fa."Fa Posting Group Depr";
                        fa.FBM_Group := fa.Group;
                        fa.FBM_Hall := fa.Hall;
                        fa."FBM_Hall Status" := fa."Hall Status";
                        fa.FBM_Location := fa.Location;
                        fa."FBM_Operator Name" := fa."Operator Name";
                        fa."FBM_Business Name" := fa."Business Name";
                        fa.modify;
                    until fa.Next() = 0;
                GenJnlLine.ChangeCompany(comp.Name);
                if GenJnlLine.FindFirst() then
                    repeat
                        GenJnlLine."FBM_Period Start" := GenJnlLine."Period Start";
                        GenJnlLine."FBM_Period End" := GenJnlLine."Period End";
                        GenJnlLine.Modify();
                    until GenJnlLine.Next() = 0;
                glaccount.ChangeCompany(comp.Name);
                if glaccount.FindFirst() then
                    repeat
                        glaccount."FBM_Periods Required" := glaccount."Periods Required";
                        glaccount.Modify();
                    until glaccount.Next() = 0;
                glentry.ChangeCompany(comp.Name);
                if glentry.FindFirst() then
                    repeat
                        glentry."FBM_Period Start" := glentry."Period Start";
                        glentry."FBM_Period End" := glentry."Period End";
                        glentry.Modify();
                    until glentry.Next() = 0;
                sheader.ChangeCompany(comp.Name);
                if sheader.FindFirst() then
                    repeat
                        sheader."FBM_Billing Statement" := sheader."Billing Statement";
                        sheader."FBM_Contract Code" := sheader."Contract Code";
                        sheader.FBM_Site := sheader.Site;
                        sheader."FBM_Period Start" := sheader."Period Start";
                        sheader."FBM_Period End" := sheader."Period End";
                        sheader.Modify();
                    until sheader.Next() = 0;
                sline.ChangeCompany(comp.Name);
                if sline.FindFirst() then
                    repeat
                        sline.FBM_IsPeriodEnabled := sline.IsPeriodEnabled;
                        sline.FBM_Site := sline.Site;
                        sline."FBM_Period Start" := sline."Period Start";
                        sline."FBM_Period End" := sline."Period End";
                        sline.Modify();
                    until sline.Next() = 0;
                siheader.ChangeCompany(comp.Name);
                if siheader.FindFirst() then
                    repeat
                        siheader."FBM_Billing Statement" := siheader."Billing Statement";
                        siheader."FBM_Contract Code" := siheader."Contract Code";
                        siheader.FBM_Site := siheader.Site;
                        siheader."FBM_Period Start" := siheader."Period Start";
                        siheader."FBM_Period End" := siheader."Period End";
                        siheader.Modify();
                    until siheader.Next() = 0;
                siline.ChangeCompany(comp.Name);
                if siline.FindFirst() then
                    repeat

                        siline.FBM_Site := siline.Site;
                        siline."FBM_Period Start" := siline."Period Start";
                        siline."FBM_Period End" := siline."Period End";
                        siline.Modify();
                    until siline.Next() = 0;
                scheader.ChangeCompany(comp.Name);
                if scheader.FindFirst() then
                    repeat

                        scheader."FBM_Contract Code" := scheader."Contract Code";
                        scheader.FBM_Site := scheader.Site;
                        scheader."FBM_Period Start" := scheader."Period Start";
                        scheader."FBM_Period End" := scheader."Period End";
                        scheader.Modify();
                    until scheader.Next() = 0;
                scline.ChangeCompany(comp.Name);
                if scline.FindFirst() then
                    repeat

                        scline.FBM_Site := scline.Site;
                        scline."FBM_Period Start" := scline."Period Start";
                        scline."FBM_Period End" := scline."Period End";
                        scline.Modify();
                    until scline.Next() = 0;
                salessetup.ChangeCompany();
                if salessetup.Get() then begin
                    salessetup."FBM_Show Hall Invoice Warning" := salessetup."Show Hall Invoice Warning";
                    salessetup.Modify();
                end;
                usetup.ChangeCompany(comp.Name);
                if usetup.FindFirst() then
                    repeat
                        usetup."FBM_See LCY in Journals" := usetup."See LCY in Journals";
                        usetup."FBM_Approve Finance":=usetup."Approve Finance";
                        usetup."FBM_Item Filter":=usetup."Item Filter";
                        usetup."FBM_Bank Filter":=usetup."Bank Filter";
                        usetup.Modify();
                    until usetup.Next() = 0;
                vendorle.ChangeCompany(comp.Name);
                if vendorle.FindFirst() then
                    repeat
                        vendorle.FBM_approved := vendorle.approved;
                        vendorle."FBM_approved date" := vendorle."approved date";
                        vendorle."FBM_approved user" := vendorle."approved user";
                        vendorle."FBM_Approver Comment" := vendorle."Approver Comment";

                        vendorle."FBM_Default Bank Account" := vendorle."Default Bank Account";
                        vendorle.Modify();
                    until vendorle.Next() = 0;
                detvendorle.ChangeCompany(comp.Name);
                if detvendorle.FindFirst() then
                    repeat
                        detvendorle."FBM_Default Bank Account" := detvendorle."Default Bank Account";
                        detvendorle.FBM_approved := detvendorle.approved;
                        detvendorle.FBM_open := detvendorle.open;
                        detvendorle.Modify();
                    until detvendorle.Next() = 0;
                vendor.ChangeCompany(comp.Name);
                if vendor.FindFirst() then
                    repeat
                        vendor."FBM_Default Bank Account" := vendor."Default Bank Account";
                        vendor."FBM_Print Name on Check" := vendor."Print Name on Check";
                        vendor.Modify();
                    until vendor.Next() = 0;
                bankacc.ChangeCompany(comp.Name);
                if bankacc.FindFirst() then
                    repeat
                        bankacc."FBM_Approval Batch Amount" := bankacc."Approval Batch Amount";
                        bankacc."FBM_Approval Batch Amount2" := bankacc."Approval Batch Amount2";
                        bankacc.Modify();
                    until bankacc.Next() = 0;
                itemle.ChangeCompany(comp.Name);
                if itemle.FindFirst() then
                    repeat
                        itemle."FBM_Document No Value Entry" := itemle."Document No Value Entry";
                        itemle.Modify();
                    until itemle.Next() = 0;
            until comp.Next() = 0;
    end;
}