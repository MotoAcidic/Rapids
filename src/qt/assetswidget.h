// Copyright (c) 2018-2022 The Rapids developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef ASSETSWIDGET_H
#define ASSETSWIDGET_H

#include <QWidget>
#include "qt/rapids/pwidget.h"
#include "qt/creatempdialog.h"
#include "qt/usernamesdialog.h"
#include "qt/txhistorydialog.h"
#include "qt/sendmpdialog.h"
#include "qt/tradehistorydialog.h"

class RapidsGUI;

QT_BEGIN_NAMESPACE
class QDataWidgetMapper;
QT_END_NAMESPACE

namespace Ui {
class AssetsWidget;
}

class AssetsWidget : public PWidget
{
    Q_OBJECT

public:
    explicit AssetsWidget(RapidsGUI* parent);
    ~AssetsWidget();


    void loadClientModel() override;
    void loadWalletModel() override;
    void setMapper();
    void showTokenCreate();
    void showTokenUsername();
    void showTokenHistory();
    void showTokenSend();

Q_SIGNALS:
    /** Get restart command-line parameters and handle restart */
    void handleRestart(QStringList args);

private Q_SLOTS:
    // Create Token
    void onTokenCreateClicked();

    // Username
    void onTokenUsernamesClicked();

    // Token History
    void onTokenHistoryClicked();

    // Token Send
    void onTokenSendClicked();

private:
    Ui::AssetsWidget *ui;
    int navAreaBaseHeight{0};

    CreateMPDialog* assetsTokenCreate;
    UsernamesDialog* assetsTokenUsernames;
    TradeHistoryObject* assetsTokenHistory;
    SendMPDialog* assetsTokenSend;

    QDataWidgetMapper* mapper;

    QList<QPushButton*> options;
    // Map of: menu button -> sub menu items
    QMap <QPushButton*, QWidget*> menus;

    void selectOption(QPushButton* option);
    bool openStandardDialog(const QString& title = "", const QString& body = "", const QString& okBtn = "OK", const QString& cancelBtn = "");
    void selectMenu(QPushButton* btn);
};

#endif // ASSETSWIDGET_H
