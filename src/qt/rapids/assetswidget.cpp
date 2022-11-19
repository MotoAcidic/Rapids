#include "qt/rapids/assetswidget.h"
#include "ui_assetswidget.h"

AssetsWidget::AssetsWidget(QWidget *parent) :
    QFrame(parent),
    ui(new Ui::AssetsWidget)
{
    ui->setupUi(this);
}

AssetsWidget::~AssetsWidget()
{
    delete ui;
}

void AssetsWidget::on_pushButton_9_clicked()
{

}

