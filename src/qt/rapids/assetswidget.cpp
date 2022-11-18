#include "qt/rapids/assetswidget.h"
#include "qt/rapids/forms/ui_assetswidget.h"
#include "clientmodel.h"
#include "optionsmodel.h"
#include "qt/rapids/optionbutton.h"


AssetsWidget::AssetsWidget(RapidsGUI* parent) : PWidget(parent),
              ui(new Ui::assetswidget),
              coinIcon(new QPushButton())
{
    ui->setupUi(this);

    this->setStyleSheet(parent->styleSheet());

    /* Containers */
    setCssProperty(ui->left, "container");
    ui->left->setContentsMargins(0, 20, 0, 20);
    setCssProperty(ui->right, "container-right");
    ui->right->setContentsMargins(20, 10, 20, 20);

    /* Light Font */
    QFont fontLight;
    fontLight.setWeight(QFont::Light);

    /* Title */
    setCssProperty(ui->labelTitle, "text-title-screen");
    ui->labelTitle->setFont(fontLight);

    /* Subtitle */
    setCssProperty(ui->labelSubtitle1, "text-subtitle");

    /* Address - Amount*/
    setCssProperty({ui->labelSubtitleAddress, ui->labelSubtitleAmount}, "text-title");

    /* Buttons */
    setCssBtnSecondary(ui->pushButtonFee);
    setCssProperty(ui->pushButtonClear, "btn-secundary-clear");
    setCssProperty(ui->pushButtonAddRecipient, "btn-secundary-add");
    setCssBtnPrimary(ui->pushButtonSave);
    setCssBtnSecondary(ui->pushButtonReset);

    // Coin control
    //ui->btnCoinControl->setTitleClassAndText("btn-title-grey", tr("Coin Control"));
    //ui->btnCoinControl->setSubTitleClassAndText("text-subtitle", tr("Select the source of the coins"));

    //connect(ui->pushButtonFee, &QPushButton::clicked, this, &SendWidget::onChangeCustomFeeClicked);
    //connect(ui->btnCoinControl, &OptionButton::clicked, this, &SendWidget::onCoinControlClicked);

    //setCssProperty(ui->coinWidget, "container-coin-type");
    //setCssProperty(ui->labelLine, "container-divider");


    // Total Send
    //setCssProperty(ui->labelTitleTotalSend, "text-title");
    //setCssProperty(ui->labelAmountSend, "text-body1");

    // Icon Send
    ui->stackedWidget->addWidget(coinIcon);
    coinIcon->show();
    coinIcon->raise();

    setCssProperty(coinIcon, "coin-icon-rpd");

    QSize BUTTON_SIZE = QSize(24, 24);
    coinIcon->setMinimumSize(BUTTON_SIZE);
    coinIcon->setMaximumSize(BUTTON_SIZE);

    int posX = 0;
    int posY = 20;
    coinIcon->move(posX, posY);

    // Connect
    //connect(ui->pushButtonSave, &QPushButton::clicked, this, &SendWidget::onSendClicked);
    //connect(ui->pushButtonAddRecipient, &QPushButton::clicked, this, &SendWidget::onAddEntryClicked);
    //connect(ui->pushButtonClear, &QPushButton::clicked, [this]() { clearAll(true); });

}

void AssetsWidget::loadClientModel()
{
    if (clientModel) {
        connect(clientModel, &ClientModel::numBlocksChanged, [this]() {
            if (customFeeDialog) customFeeDialog->updateFee();
        });
    }
}

void AssetsWidget::resizeEvent(QResizeEvent* event)
{
    resizeMenu();
    QWidget::resizeEvent(event);
}

void SendWidget::resizeMenu()
{
    if (menuContacts && menuContacts->isVisible() && focusedEntry) {
        int width = focusedEntry->getEditWidth();
        menuContacts->resizeList(width, menuContacts->height());
        menuContacts->resize(width, menuContacts->height());
        QPoint pos = focusedEntry->getEditLineRect().bottomLeft();
        pos.setX(pos.x() + 20);
        pos.setY(pos.y() + ((focusedEntry->getEditHeight() - 12) * 3));
        menuContacts->move(pos);
    }
}

AssetsWidget::~AssetsWidget()
{
    delete ui;
}
