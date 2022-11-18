#ifndef ASSETSWIDGET_H
#define ASSETSWIDGET_H

#include <QFrame>
#include <QWidget>
#include <QPushButton>

#include "qt/rapids/pwidget.h"
#include "walletmodel.h"
#include "qt/rapids/tooltipmenu.h"

class RapidsGUI;
class ClientModel;
class WalletModel;

namespace Ui {
class AssetsWidget;
class QPushButton;
}

class AssetsWidget : public PWidget
{
    Q_OBJECT

public:
    explicit AssetsWidget(RapidsGUI* parent);
    ~AssetsWidget();

    void loadClientModel() override;

//public Q_SLOTS:
    //void onChangeAddressClicked();
    //void onChangeCustomFeeClicked();
    //void onCoinControlClicked();

protected:
    void resizeEvent(QResizeEvent* event) override;

private Q_SLOTS:
    void onAssetsClicked();
    //void onContactsClicked(SendMultiRow* entry);
    //void onMenuClicked(SendMultiRow* entry);
    //void onContactMultiClicked();
    //void onDeleteClicked();
    //void onResetCustomOptions(bool fRefreshAmounts);

private:
    Ui::AssetsWidget* ui;
    QPushButton* coinIcon;

    BalancesDialog* balancesDialog;

    //ContactsDropdown* menuContacts = nullptr;
    TooltipMenu* menu = nullptr;
    // Current focus entry
    //SendMultiRow* focusedEntry = nullptr;

    void resizeMenu();

};

#endif // ASSETSWIDGET_H
