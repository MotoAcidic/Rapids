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


private:
    Ui::AssetsWidget *ui;
    int navAreaBaseHeight{0};

};

#endif // ASSETSWIDGET_H
