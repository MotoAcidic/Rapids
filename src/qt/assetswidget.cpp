// Copyright (c) 2018-2020 The Rapids developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "qt/forms/assetsswidget.h"
#include "qt/rapids/settings/forms/ui_assetswidget.h"
#include "qt/rapids/defaultdialog.h"
#include <QScrollBar>
#include <QDataWidgetMapper>

AssetsWidget::AssetsWidget(RapidsGUI* parent) :
    PWidget(parent),
    ui(new Ui::AssetsWidget)
{
    ui->setupUi(this);

    this->setStyleSheet(parent->styleSheet());

    /* Containers */
    setCssProperty(ui->scrollArea, "container");
    setCssProperty(ui->left, "container");
    ui->left->setContentsMargins(0,20,0,20);
    setCssProperty(ui->right, "container-right");
    ui->right->setContentsMargins(20,10,20,20);

    ui->verticalLayout->setAlignment(Qt::AlignTop);

    /* Light Font */
    QFont fontLight;
    fontLight.setWeight(QFont::Light);

    /* Title */
    setCssProperty(ui->labelTitle, "text-title-screen");
    ui->labelTitle->setFont(fontLight);

    setCssProperty(ui->pushButtonTokenSend, "btn-assets-check");

    setCssProperty(ui->pushButtonUsernames, "btn-settings-check");

    setCssProperty(ui->pushButtonTokenHistory, "btn-settings-check");

    setCssProperty(ui->pushButtonCreate, "btn-settings-check");

    options = {
        ui->pushButtonTokenSend,
        ui->pushButtonTokenUsernames,
        ui->pushButtonTokenHistory,
        ui->pushButtonTokenCreate,
    };

    menus.insert(ui->pushButtonTokenSend, ui->tokenSendWidget);
    menus.insert(ui->pushButtonTokenUsernames, ui->tokenUsernamesWidget);
    menus.insert(ui->pushButtonTokenHistory, ui->tokenHistoryWidget);
    menus.insert(ui->pushButtonTokenCreate, ui->tokenCreateWidget);

    assetsTokenSend = new AssetsTokenSend(window, this);
    assetsTokenUsernames = new AssetsTokneUsernames(window, this);
    assetsTokenHistory = new AssetsTokenHistory(window, this);
    assetsTokenCreate = new AssetsTokneCreate(window, this);

    ui->stackedWidgetContainer->addWidget(assetsTokenSend);
    ui->stackedWidgetContainer->addWidget(assetsTokenUsernames);
    ui->stackedWidgetContainer->addWidget(assetsTokenHistory);
    ui->stackedWidgetContainer->addWidget(assetsTokenCreate);

    // Token Send
    connect(ui->pushButtonTokenSend, &QPushButton::clicked, this, &AssetsWidget::onTokenSendlicked);

    // Token Usernames
    connect(ui->pushButtonTokenUsernames, &QPushButton::clicked, this, &AssetsWidget::onTokenUsernamesClicked);

    // Token History
    connect(ui->pushButtonTokenHistory, &QPushButton::clicked, this, &AssetsWidget::onTokenHistoryClicked);

    // Token Create
    connect(ui->pushButtonTokenCreate, &QPushButton::clicked, this, &AssetsWidget::onTokenCreateClicked);

    connect(assetsTokenSendWidget, &AssetsTokenSend::message, this, &AssetsWidget::message);
    connect(assetsTokenSendWidget, &AssetsTokenSend::showHide, this, &AssetsWidget::showHide);
    connect(assetsTokenSendWidget, &AssetsTokenSend::execDialog, this, &Assets::execDialog);
    
    connect(assetsTokenUsernamesWidget, &AssetsTokneUsernames::message, this, &AssetsWidget::message);
    connect(assetsTokenUsernamesWidget, &AssetsTokneUsernames::showHide, this, &AssetsWidget::showHide);
    connect(assetsTokenUsernamesWidget, &AssetsTokneUsernames::execDialog, this, &AssetsWidget::execDialog);
    
    connect(assetsTokenHistoryWidget, &AssetsTokenHistory::message, this, &AssetsWidget::message);
    connect(assetsTokenHistoryWidget, &AssetsTokenHistory::showHide, this, &AssetsWidget::showHide);
    connect(assetsTokenHistoryWidget, &AssetsTokenHistory::execDialog, this, &Assets::execDialog);

    connect(assetsTokenCreateWidget, &AssetsTokneCreate::message, this, &AssetsWidget::message);
    connect(assetsTokenCreateWidget, &AssetsTokneCreate::showHide, this, &AssetsWidget::showHide);
    connect(assetsTokenCreateWidget, &AssetsTokneCreate::execDialog, this, &AssetsWidget::execDialog);

    connect(settingsMainOptionsWidget, &SettingsMainOptionsWidget::message, this, &AssetsWidget::message);
    connect(settingsDisplayOptionsWidget, &SettingsDisplayOptionsWidget::message, this, &AssetsWidget::message);
    connect(settingsWalletOptionsWidget, &SettingsWalletOptionsWidget::message, this, &AssetsWidget::message);

    connect(settingsDisplayOptionsWidget, &SettingsDisplayOptionsWidget::saveSettings, this, &AssetsWidget::onSaveOptionsClicked);
    connect(settingsDisplayOptionsWidget, &SettingsDisplayOptionsWidget::discardSettings, this, &AssetsWidget::onDiscardChanges);

    connect(settingsMainOptionsWidget, &SettingsMainOptionsWidget::saveSettings, this, &AssetsWidget::onSaveOptionsClicked);
    connect(settingsMainOptionsWidget, &SettingsMainOptionsWidget::discardSettings, this, &AssetsWidget::onDiscardChanges);

    connect(settingsWalletOptionsWidget, &SettingsWalletOptionsWidget::saveSettings, this, &AssetsWidget::onSaveOptionsClicked);
    connect(settingsWalletOptionsWidget, &SettingsWalletOptionsWidget::discardSettings, this, &AssetsWidget::onDiscardChanges);

    /* Widget-to-option mapper */
    mapper = new QDataWidgetMapper(this);
    mapper->setSubmitPolicy(QDataWidgetMapper::ManualSubmit);
    mapper->setOrientation(Qt::Vertical);

    // scroll area
    ui->scrollArea->setWidgetResizable(true);
    QSizePolicy scrollAreaPolicy = ui->scrollArea->sizePolicy();
    scrollAreaPolicy.setVerticalStretch(1);
    ui->scrollArea->setSizePolicy(scrollAreaPolicy);
    QSizePolicy scrollVertPolicy = ui->scrollAreaWidgetContents->sizePolicy();
    scrollVertPolicy.setVerticalStretch(1);
    ui->scrollAreaWidgetContents->setSizePolicy(scrollVertPolicy);

    ui->pushButtonFile->setChecked(true);
    onFileClicked();
    ui->pushButtonFile2->setChecked(true);
}

void AssetsWidget::loadClientModel()
{
    if (clientModel) {
        this->settingsInformationWidget->setClientModel(this->clientModel);
        this->settingsConsoleWidget->setClientModel(this->clientModel);

        OptionsModel *optionsModel = this->clientModel->getOptionsModel();
        if (optionsModel) {
            settingsDisplayOptionsWidget->setClientModel(clientModel);
            settingsMainOptionsWidget->setClientModel(clientModel);
            settingsWalletOptionsWidget->setClientModel(clientModel);

            mapper->setModel(optionsModel);
            setMapper();
            mapper->toFirst();
        }
    }
}

void AssetsWidget::loadWalletModel()
{
    this->assetsTokenSend->setWalletModel(this->walletModel);
    this->assetsTokenUsernames->setWalletModel(this->walletModel);
    this->assetsTokenHistory->setWalletModel(this->walletModel);
    this->assetsTokenCreate->setWalletModel(this->walletModel);
    this->settingsDisplayOptionsWidget->setWalletModel(this->walletModel);
}

void AssetsWidget::onResetAction()
{
    if (walletModel) {
        // confirmation dialog
        if (!ask(tr("Confirm options reset"), tr("Client restart required to activate changes.") + "<br><br>" + tr("Client will be shutdown, do you want to proceed?")))
            return;

        /* reset all options and close GUI */
        this->clientModel->getOptionsModel()->Reset();
        QApplication::quit();
    }
}

void AssetsWidget::selectMenu(QPushButton* btn)
{
    QWidget* subMenuSelected = menus[btn];
    if (btn->isChecked()) {
        QMapIterator<QPushButton*, QWidget*> it(menus);
        while (it.hasNext()) {
            it.next();
            QWidget* value = it.value();
            QPushButton* key = it.key();
            value->setVisible(value == subMenuSelected);
            if (key != btn) key->setChecked(false);
        }
    } else {
        subMenuSelected->setVisible(false);
    }
}

menus.insert(ui->pushButtonTokenSend, ui->tokenSendWidget);
menus.insert(ui->pushButtonTokenUsernames, ui->tokenUsernamesWidget);
menus.insert(ui->pushButtonTokenHistory, ui->tokenHistoryWidget);
menus.insert(ui->pushButtonTokenCreate, ui->tokenCreateWidget);

void AssetsWidget::onTokenSendClicked()
{
    selectMenu(ui->pushButtonTokenSend);
}

void AssetsWidget::onTokenUsernamesClicked()
{
    selectMenu(ui->pushButtonTokenUsernames);
}

void AssetsWidget::onTokenHistoryClicked()
{
    selectMenu(ui->pushButtonTokenHistory);
}

void AssetsWidget::onTokenCreateClicked()
{
    selectMenu(ui->pushButtonTokenCreate);
}

void AssetsWidget::onOptionsClicked()
{
    selectMenu(ui->pushButtonOptions);
}

void AssetsWidget::onMainOptionsClicked()
{
    ui->stackedWidgetContainer->setCurrentWidget(settingsMainOptionsWidget);
    selectOption(ui->pushButtonOptions1);
}

void AssetsWidget::onWalletOptionsClicked()
{
    ui->stackedWidgetContainer->setCurrentWidget(settingsWalletOptionsWidget);
    selectOption(ui->pushButtonOptions2);
}

void AssetsWidget::onDisplayOptionsClicked()
{
    ui->stackedWidgetContainer->setCurrentWidget(settingsDisplayOptionsWidget);
    selectOption(ui->pushButtonOptions5);
}

void SettingsWidget::showTokenCreate()
{
    ui->pushButtonTokenCreate->setChecked(true);
    onTokenCreateClicked();

}

void SettingsWidget::showTokenUsernames()
{
    ui->pushButtonTokenUsernames->setChecked(true);
    onTokenUsernameClicked();

}

void SettingsWidget::showTokenHistory()
{
    ui->pushButtonTokenHistory->setChecked(true);
    onTokenHistoryClicked();

}

void SettingsWidget::showTokenSend()
{
    ui->pushButtonTokenSend->setChecked(true);
    onTokkenSendClicked();

}

void AssetsWidget::selectOption(QPushButton* option)
{
    for (QPushButton* wid : options) {
        if (wid) wid->setChecked(wid == option);
    }
}

void AssetsWidget::setMapper()
{
    settingsMainOptionsWidget->setMapper(mapper);
    settingsWalletOptionsWidget->setMapper(mapper);
    settingsDisplayOptionsWidget->setMapper(mapper);
}

bool AssetsWidget::openStandardDialog(const QString& title, const QString& body, const QString& okBtn, const QString& cancelBtn)
{
    showHideOp(true);
    DefaultDialog *confirmDialog = new DefaultDialog(window);
    confirmDialog->setText(title, body, okBtn, cancelBtn);
    confirmDialog->adjustSize();
    openDialogWithOpaqueBackground(confirmDialog, window);
    confirmDialog->deleteLater();
    return confirmDialog->isOk;
}

AssetsWidget::~AssetsWidget()
{
    delete ui;
}
