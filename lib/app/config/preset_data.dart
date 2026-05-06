import '../../data/models/account.dart';
import '../../data/models/knowledge_card.dart';

List<Account> presetAccounts = [
  // ============ 资产类 Assets ============
  Account(id: '1001', nameZh: '库存现金', nameEn: 'Cash on Hand', nameKo: '현금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true, openingBalance: 10000,
      explanationZh: '企业存放在保险柜中的货币资金。', explanationEn: 'Currency held by the business in its safe.', explanationKo: '기업이 금고에 보관하는 통화.'),
  Account(id: '1002', nameZh: '银行存款', nameEn: 'Bank Deposit', nameKo: '은행예금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true, openingBalance: 100000,
      explanationZh: '企业存放在银行账户中的资金。', explanationEn: 'Funds held in the bank account.', explanationKo: '은행 계좌에 보관된 자금.'),
  Account(id: '1012', nameZh: '其他货币资金', nameEn: 'Other Monetary Assets', nameKo: '기타 화폐 자산', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1101', nameZh: '交易性金融资产', nameEn: 'Trading Financial Assets', nameKo: '매매금융자산', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1121', nameZh: '应收票据', nameEn: 'Notes Receivable', nameKo: '받을어음', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1122', nameZh: '应收账款', nameEn: 'Accounts Receivable', nameKo: '외상매출금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1123', nameZh: '预付账款', nameEn: 'Prepaid Accounts', nameKo: '선급금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1131', nameZh: '应收股利', nameEn: 'Dividends Receivable', nameKo: '미수배당금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1132', nameZh: '应收利息', nameEn: 'Interest Receivable', nameKo: '미수이자', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1221', nameZh: '其他应收款', nameEn: 'Other Receivables', nameKo: '기타 미수금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1231', nameZh: '坏账准备', nameEn: 'Bad Debt Provision', nameKo: '대손충당금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true, openingBalance: 0,
      explanationZh: '应收账款中预计无法收回的金额。坏账准备是应收账款的备抵科目。', explanationEn: 'Estimated uncollectible amounts in accounts receivable. This is a contra-asset account.', explanationKo: '회수 불가능할 것으로 예상되는 외상매출금. 자산의 차감 계정입니다.'),
  Account(id: '1401', nameZh: '材料采购', nameEn: 'Material Procurement', nameKo: '재료구매', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1403', nameZh: '原材料', nameEn: 'Raw Materials', nameKo: '원재료', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true, openingBalance: 50000),
  Account(id: '1405', nameZh: '库存商品', nameEn: 'Finished Goods', nameKo: '제품', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true, openingBalance: 80000),
  Account(id: '1411', nameZh: '周转材料', nameEn: 'Revolving Materials', nameKo: '회전자재', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1471', nameZh: '存货跌价准备', nameEn: 'Inventory Write-down', nameKo: '재고평가손실충당금', category: 'asset', subCategory: 'current_asset', type: 1, isSystem: true),
  Account(id: '1501', nameZh: '持有至到期投资', nameEn: 'Held-to-Maturity Investments', nameKo: '만기보유투자', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1511', nameZh: '长期股权投资', nameEn: 'Long-term Equity Investment', nameKo: '장기지분투자', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1601', nameZh: '固定资产', nameEn: 'Fixed Assets', nameKo: '고정자산', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true, openingBalance: 200000,
      explanationZh: '企业为生产商品、提供劳务或经营管理而持有的、使用寿命超过一个会计年度的有形资产。', explanationEn: 'Tangible assets held for producing goods, providing services, or administrative purposes with a useful life exceeding one year.', explanationKo: '상품 생산, 용역 제공 또는 관리 목적으로 보유하는 내용연수 1년 이상의 유형자산.'),
  Account(id: '1602', nameZh: '累计折旧', nameEn: 'Accumulated Depreciation', nameKo: '감가상각누계액', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true, openingBalance: -20000,
      explanationZh: '固定资产因使用损耗而累计减少的价值。是固定资产的备抵科目。', explanationEn: 'The cumulative reduction in value of fixed assets due to usage. This is a contra-asset account.', explanationKo: '사용에 따른 고정자산 가치의 누적 감소액. 자산의 차감 계정입니다.'),
  Account(id: '1604', nameZh: '在建工程', nameEn: 'Construction in Progress', nameKo: '건설중인자산', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1606', nameZh: '固定资产清理', nameEn: 'Fixed Asset Disposal', nameKo: '고정자산처분', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1701', nameZh: '无形资产', nameEn: 'Intangible Assets', nameKo: '무형자산', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1702', nameZh: '累计摊销', nameEn: 'Accumulated Amortization', nameKo: '무형자산상각누계액', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1801', nameZh: '长期待摊费用', nameEn: 'Long-term Prepaid Expenses', nameKo: '장기선급비용', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),
  Account(id: '1901', nameZh: '待处理财产损溢', nameEn: 'Pending Property Loss/Gain', nameKo: '미처리재산손익', category: 'asset', subCategory: 'noncurrent_asset', type: 1, isSystem: true),

  // ============ 负债类 Liabilities ============
  Account(id: '2001', nameZh: '短期借款', nameEn: 'Short-term Loans', nameKo: '단기차입금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2201', nameZh: '应付票据', nameEn: 'Notes Payable', nameKo: '지급어음', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2202', nameZh: '应付账款', nameEn: 'Accounts Payable', nameKo: '외상매입금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true, openingBalance: 30000),
  Account(id: '2203', nameZh: '预收账款', nameEn: 'Advances from Customers', nameKo: '선수금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2211', nameZh: '应付职工薪酬', nameEn: 'Payroll Payable', nameKo: '미지급임금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2221', nameZh: '应交税费', nameEn: 'Tax Payable', nameKo: '미지급세금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2231', nameZh: '应付利息', nameEn: 'Interest Payable', nameKo: '미지급이자', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2232', nameZh: '应付股利', nameEn: 'Dividends Payable', nameKo: '미지급배당금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2241', nameZh: '其他应付款', nameEn: 'Other Payables', nameKo: '기타 미지급금', category: 'liability', subCategory: 'current_liability', type: 2, isSystem: true),
  Account(id: '2501', nameZh: '长期借款', nameEn: 'Long-term Loans', nameKo: '장기차입금', category: 'liability', subCategory: 'noncurrent_liability', type: 2, isSystem: true),
  Account(id: '2502', nameZh: '应付债券', nameEn: 'Bonds Payable', nameKo: '사채', category: 'liability', subCategory: 'noncurrent_liability', type: 2, isSystem: true),
  Account(id: '2701', nameZh: '长期应付款', nameEn: 'Long-term Payables', nameKo: '장기미지급금', category: 'liability', subCategory: 'noncurrent_liability', type: 2, isSystem: true),

  // ============ 所有者权益类 Owner's Equity ============
  Account(id: '3001', nameZh: '实收资本', nameEn: 'Paid-in Capital', nameKo: '자본금', category: 'equity', subCategory: 'equity', type: 3, isSystem: true, openingBalance: 390000,
      explanationZh: '投资者实际投入企业的资本。', explanationEn: 'Capital actually invested by the owners.', explanationKo: '투자자가 실제로 기업에 투자한 자본.'),
  Account(id: '3002', nameZh: '资本公积', nameEn: 'Capital Reserve', nameKo: '자본잉여금', category: 'equity', subCategory: 'equity', type: 3, isSystem: true),
  Account(id: '3101', nameZh: '盈余公积', nameEn: 'Surplus Reserve', nameKo: '이익잉여금', category: 'equity', subCategory: 'equity', type: 3, isSystem: true),
  Account(id: '3103', nameZh: '本年利润', nameEn: 'Current Year Profit', nameKo: '당기순이익', category: 'equity', subCategory: 'equity', type: 3, isSystem: true,
      explanationZh: '企业在本年度累计实现的净利润（或亏损）。', explanationEn: 'The cumulative net profit (or loss) realized in the current year.', explanationKo: '당해 연도 누적 순이익(또는 손실).'),
  Account(id: '3104', nameZh: '利润分配', nameEn: 'Profit Distribution', nameKo: '이익처분', category: 'equity', subCategory: 'equity', type: 3, isSystem: true),

  // ============ 成本类 Costs ============
  Account(id: '4001', nameZh: '生产成本', nameEn: 'Production Cost', nameKo: '생산원가', category: 'cost', subCategory: 'cost', type: 4, isSystem: true,
      explanationZh: '生产产品过程中发生的直接材料、直接人工和制造费用。', explanationEn: 'Direct materials, direct labor, and manufacturing overhead incurred in production.', explanationKo: '제품 생산 과정에서 발생하는 직접재료비, 직접노무비 및 제조간접비.'),
  Account(id: '4101', nameZh: '制造费用', nameEn: 'Manufacturing Overhead', nameKo: '제조간접비', category: 'cost', subCategory: 'cost', type: 4, isSystem: true),

  // ============ 损益类 - 收入 P&L - Revenue ============
  Account(id: '5001', nameZh: '主营业务收入', nameEn: 'Main Operating Revenue', nameKo: '주된영업수익', category: 'pl', subCategory: 'income', type: 5, isSystem: true,
      explanationZh: '企业日常经营活动产生的收入。', explanationEn: 'Revenue generated from the main operating activities.', explanationKo: '주된 영업 활동에서 발생하는 수익.'),
  Account(id: '5051', nameZh: '其他业务收入', nameEn: 'Other Operating Revenue', nameKo: '기타영업수익', category: 'pl', subCategory: 'income', type: 5, isSystem: true),
  Account(id: '5101', nameZh: '公允价值变动损益', nameEn: 'Fair Value Change Gain', nameKo: '공정가치변동이익', category: 'pl', subCategory: 'income', type: 5, isSystem: true),
  Account(id: '5201', nameZh: '投资收益', nameEn: 'Investment Income', nameKo: '투자수익', category: 'pl', subCategory: 'income', type: 5, isSystem: true),
  Account(id: '5301', nameZh: '营业外收入', nameEn: 'Non-operating Income', nameKo: '영업외수익', category: 'pl', subCategory: 'income', type: 5, isSystem: true),

  // ============ 损益类 - 费用 P&L - Expense ============
  Account(id: '5401', nameZh: '主营业务成本', nameEn: 'Main Operating Cost', nameKo: '주된영업원가', category: 'pl', subCategory: 'expense', type: 6, isSystem: true,
      explanationZh: '与主营业务收入相配比的成本。', explanationEn: 'Costs matched against main operating revenue.', explanationKo: '주된 영업 수익에 대응하는 원가.'),
  Account(id: '5402', nameZh: '其他业务成本', nameEn: 'Other Operating Cost', nameKo: '기타영업원가', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5403', nameZh: '税金及附加', nameEn: 'Taxes & Surcharges', nameKo: '세금및부가세', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5501', nameZh: '销售费用', nameEn: 'Selling Expenses', nameKo: '판매비', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5502', nameZh: '管理费用', nameEn: 'Administrative Expenses', nameKo: '관리비', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5503', nameZh: '财务费用', nameEn: 'Financial Expenses', nameKo: '재무비용', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5601', nameZh: '资产减值损失', nameEn: 'Asset Impairment Loss', nameKo: '자산손상차손', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5701', nameZh: '营业外支出', nameEn: 'Non-operating Expenses', nameKo: '영업외비용', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
  Account(id: '5801', nameZh: '所得税费用', nameEn: 'Income Tax Expense', nameKo: '소득세비용', category: 'pl', subCategory: 'expense', type: 6, isSystem: true),
];

List<KnowledgeCard> presetKnowledgeCards = [
  KnowledgeCard(
    id: 'k1', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '借贷记账法', titleEn: 'Double-Entry Bookkeeping', titleKo: '복식부기',
    contentZh: '''## 借贷记账法

借贷记账法是现代会计的基本记账方法。

### 核心规则：**有借必有贷，借贷必相等**

每一笔经济业务，在记入一个账户借方的同时，必然记入另一个（或几个）账户的贷方，且借方金额与贷方金额相等。

### 账户方向
- **资产类、费用类**：增加记借方，减少记贷方，余额通常在借方
- **负债类、权益类、收入类**：增加记贷方，减少记借方，余额通常在贷方

### 示例
企业从银行提取现金 5,000 元：
- 借：库存现金 5,000（资产增加）
- 贷：银行存款 5,000（资产减少）''',
    contentEn: '''## Double-Entry Bookkeeping

Double-entry bookkeeping is the fundamental recording method in modern accounting.

### Core Rule: **Every debit must have a corresponding credit**

Every transaction must be recorded as a debit in one account and a credit in another, with equal amounts on both sides.

### Account Direction
- **Assets, Expenses**: Increase on debit side, decrease on credit side, normally have debit balance
- **Liabilities, Equity, Revenue**: Increase on credit side, decrease on debit side, normally have credit balance

### Example
Company withdraws 5,000 CNY from bank:
- Dr: Cash on Hand 5,000 (asset increases)
- Cr: Bank Deposit 5,000 (asset decreases)''',
    contentKo: '''## 복식부기

복식부기는 현대 회계의 기본적인 기록 방법입니다.

### 핵심 규칙: **차변이 있으면 반드시 대변이 있다**

모든 거래는 한 계정의 차변과 다른 계정의 대변에 동일한 금액으로 기록되어야 합니다.

### 계정 방향
- **자산, 비용**: 증가는 차변, 감소는 대변, 잔액은 일반적으로 차변
- **부채, 자본, 수익**: 증가는 대변, 감소는 차변, 잔액은 일반적으로 대변

### 예시
기업이 은행에서 5,000위안 인출:
- 차: 현금 5,000 (자산 증가)
- 대: 은행예금 5,000 (자산 감소)''',
  ),
  KnowledgeCard(
    id: 'k2', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '会计基本等式', titleEn: 'Basic Accounting Equation', titleKo: '기본 회계 등식',
    contentZh: '''## 会计基本等式

### 静态等式（资产负债表基础）
**资产 = 负债 + 所有者权益**

这个等式反映企业某一时点的财务状况。等式左边是企业的资源（资产），右边是这些资源的来源（负债和所有者权益）。

### 动态等式（利润表基础）
**收入 - 费用 = 利润**

反映企业一定期间的经营成果。

### 扩展等式
**资产 = 负债 + 所有者权益 + （收入 - 费用）**

任何经济业务的发生都不会破坏会计等式的平衡关系。''',
    contentEn: '''## Basic Accounting Equation

### Static Equation (Balance Sheet basis)
**Assets = Liabilities + Owner's Equity**

This equation reflects the financial position at a point in time. The left side represents resources (assets), and the right side represents the sources of those resources (liabilities and equity).

### Dynamic Equation (Income Statement basis)
**Revenue - Expenses = Profit**

Reflects operating performance over a period.

### Extended Equation
**Assets = Liabilities + Equity + (Revenue - Expenses)**

No transaction can break the balance of the accounting equation.''',
    contentKo: '''## 기본 회계 등식

### 정태 등식 (대차대조표 기준)
**자산 = 부채 + 자본**

이 등식은 특정 시점의 재무 상태를 반영합니다. 왼쪽은 자원(자산), 오른쪽은 그 자원의 출처(부채와 자본)입니다.

### 동태 등식 (손익계산서 기준)
**수익 - 비용 = 이익**

일정 기간의 경영 성과를 반영합니다.

### 확장 등식
**자산 = 부채 + 자본 + (수익 - 비용)**

어떤 거래도 회계 등식의 균형을 깨뜨릴 수 없습니다.''',
  ),
  KnowledgeCard(
    id: 'k3', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '常见会计分录示例', titleEn: 'Common Journal Entry Examples', titleKo: '일반적인 분개 예시',
    contentZh: '''## 常见会计分录

### 1. 提取现金
| 借 | 贷 |
|---|---|
| 库存现金 | 银行存款 |

### 2. 采购原材料（款未付）
| 借 | 贷 |
|---|---|
| 原材料 | 应付账款 |

### 3. 销售商品（款存银行）
| 借 | 贷 |
|---|---|
| 银行存款 | 主营业务收入 |

### 4. 报销差旅费
| 借 | 贷 |
|---|---|
| 管理费用 | 库存现金 |

### 5. 计提折旧
| 借 | 贷 |
|---|---|
| 管理费用 | 累计折旧 |

### 6. 支付工资
| 借 | 贷 |
|---|---|
| 应付职工薪酬 | 银行存款 |

### 7. 结转本年利润
| 借 | 贷 |
|---|---|
| 主营业务收入 | 本年利润 |
| 本年利润 | 主营业务成本 |
| 本年利润 | 管理费用 |''',
    contentEn: '''## Common Journal Entries

### 1. Cash Withdrawal
| Debit | Credit |
|---|---|
| Cash on Hand | Bank Deposit |

### 2. Purchase Materials (on credit)
| Debit | Credit |
|---|---|
| Raw Materials | Accounts Payable |

### 3. Sell Goods (deposited in bank)
| Debit | Credit |
|---|---|
| Bank Deposit | Main Operating Revenue |

### 4. Reimburse Travel Expenses
| Debit | Credit |
|---|---|
| Admin. Expenses | Cash on Hand |

### 5. Record Depreciation
| Debit | Credit |
|---|---|
| Admin. Expenses | Accumulated Depreciation |

### 6. Pay Wages
| Debit | Credit |
|---|---|
| Payroll Payable | Bank Deposit |

### 7. Close Year-End
| Debit | Credit |
|---|---|
| Main Operating Revenue | Current Year Profit |
| Current Year Profit | Main Operating Cost |
| Current Year Profit | Admin. Expenses |''',
    contentKo: '''## 일반적인 분개 예시

### 1. 현금 인출
| 차변 | 대변 |
|---|---|
| 현금 | 은행예금 |

### 2. 원자재 구매 (외상)
| 차변 | 대변 |
|---|---|
| 원재료 | 외상매입금 |

### 3. 상품 판매 (은행 입금)
| 차변 | 대변 |
|---|---|
| 은행예금 | 주된영업수익 |

### 4. 출장비 정산
| 차변 | 대변 |
|---|---|
| 관리비 | 현금 |

### 5. 감가상각 기록
| 차변 | 대변 |
|---|---|
| 관리비 | 감가상각누계액 |

### 6. 임금 지급
| 차변 | 대변 |
|---|---|
| 미지급임금 | 은행예금 |

### 7. 연말 결산
| 차변 | 대변 |
|---|---|
| 주된영업수익 | 당기순이익 |
| 당기순이익 | 주된영업원가 |
| 당기순이익 | 관리비 |''',
  ),
  KnowledgeCard(
    id: 'k4', category: 'economic_law', relatedAccountId: null,
    titleZh: '增值税简介', titleEn: 'Introduction to VAT', titleKo: '부가가치세 소개',
    contentZh: '''## 增值税简介

增值税（VAT）是对商品和服务在流转过程中产生的增值额征收的一种流转税。

### 纳税人分类
- **一般纳税人**：可以抵扣进项税额，适用一般计税方法
- **小规模纳税人**：适用简易计税方法，征收率较低但不能抵扣

### 税率（中国）
- 基本税率：13%（销售货物、提供加工修理修配劳务）
- 低税率：9%（农产品、水电气等）、6%（现代服务业）

### 计税方法
应纳增值税 = 当期销项税额 - 当期进项税额

销项税额 = 销售额 × 税率
进项税额 = 购进额 × 税率

### 会计处理
- 购进货物时：借：原材料 应交税费-应交增值税（进项税额） 贷：银行存款
- 销售货物时：借：银行存款 贷：主营业务收入 应交税费-应交增值税（销项税额）''',
    contentEn: '''## Introduction to VAT

Value-Added Tax (VAT) is a turnover tax levied on the value added in the circulation of goods and services.

### Taxpayer Classification
- **General taxpayers**: Can deduct input VAT, use general tax calculation method
- **Small-scale taxpayers**: Use simplified method, lower levy rate but cannot deduct input VAT

### Tax Rates (China)
- Basic rate: 13% (goods sales, processing, repair services)
- Low rates: 9% (agricultural products, utilities), 6% (modern services)

### Calculation Method
VAT Payable = Output VAT - Input VAT

Output VAT = Sales × Rate
Input VAT = Purchases × Rate

### Accounting Treatment
- On purchase: Dr: Raw Materials, Taxes Payable-VAT(input) Cr: Bank Deposit
- On sale: Dr: Bank Deposit Cr: Main Operating Revenue, Taxes Payable-VAT(output)''',
    contentKo: '''## 부가가치세 소개

부가가치세(VAT)는 상품과 서비스의 유통 과정에서 발생하는 부가가치에 부과되는 유통세입니다.

### 납세자 분류
- **일반 납세자**: 매입세액 공제 가능, 일반 과세 방법 사용
- **간이 과세자**: 간이 과세 방법 사용, 낮은 세율이지만 매입세액 공제 불가

### 세율 (중국)
- 기본 세율: 13% (상품 판매, 가공, 수리 서비스)
- 낮은 세율: 9% (농산물, 공공요금), 6% (현대 서비스업)

### 계산 방법
납부할 VAT = 매출세액 - 매입세액

매출세액 = 매출액 × 세율
매입세액 = 매입액 × 세율

### 회계 처리
- 구매 시: 차: 원재료, 미지급세금-VAT(매입) 대: 은행예금
- 판매 시: 차: 은행예금 대: 주된영업수익, 미지급세금-VAT(매출)''',
  ),
  KnowledgeCard(
    id: 'k5', category: 'economic_law', relatedAccountId: null,
    titleZh: '合同法基本要点', titleEn: 'Key Points of Contract Law', titleKo: '계약법 기본 사항',
    contentZh: '''## 合同法基本要点

### 合同的成立
- **要约**：一方当事人向对方提出订立合同的意思表示
- **承诺**：受要约人同意要约的意思表示
- 合同自承诺生效时成立

### 合同的主要条款
1. 当事人的名称或姓名和住所
2. 标的（合同涉及的对象）
3. 数量
4. 质量
5. 价款或报酬
6. 履行期限、地点和方式
7. 违约责任
8. 解决争议的方法

### 合同的效力
- **有效合同**：当事人具备相应能力、意思表示真实、内容合法
- **无效合同**：欺诈胁迫损害国家利益、恶意串通、以合法形式掩盖非法目的等
- **可撤销合同**：重大误解、显失公平、欺诈胁迫

### 违约责任
- 继续履行
- 采取补救措施
- 赔偿损失
- 支付违约金''',
    contentEn: '''## Key Points of Contract Law

### Formation of Contract
- **Offer**: One party proposes to enter into a contract
- **Acceptance**: The offeree agrees to the offer
- A contract is formed when acceptance takes effect

### Main Terms of a Contract
1. Names and addresses of the parties
2. Subject matter
3. Quantity
4. Quality
5. Price or remuneration
6. Performance period, place, and method
7. Liability for breach
8. Dispute resolution methods

### Validity of Contracts
- **Valid**: Parties have capacity, genuine intent, lawful content
- **Invalid**: Fraud/coercion harming state interests, malicious collusion, concealing illegal purposes
- **Voidable**: Material misunderstanding, grossly unfair, fraud/coercion

### Remedies for Breach
- Specific performance
- Remedial measures
- Damages
- Liquidated damages''',
    contentKo: '''## 계약법 기본 사항

### 계약의 성립
- **청약**: 일방 당사자가 상대방에게 계약 체결 의사를 표시
- **승낙**: 청약 상대방이 청약에 동의하는 의사 표시
- 계약은 승낙이 효력을 발생할 때 성립

### 계약의 주요 조항
1. 당사자의 명칭 및 주소
2. 목적물
3. 수량
4. 품질
5. 가격 또는 보수
6. 이행 기한, 장소 및 방법
7. 채무불이행 책임
8. 분쟁 해결 방법

### 계약의 효력
- **유효한 계약**: 당사자 능력, 진실한 의사, 적법한 내용
- **무효 계약**: 국가 이익 침해, 악의적 공모, 위법 목적 은폐 등
- **취소 가능 계약**: 중대한 오해, 현저히 불공정, 사기/강박

### 채무불이행 구제
- 이행 강제
- 시정 조치
- 손해 배상
- 위약금 지급''',
  ),
  KnowledgeCard(
    id: 'k6', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '期末结转步骤', titleEn: 'Period-End Closing Steps', titleKo: '기말 결산 절차',
    contentZh: '''## 期末结转步骤

### 第一步：结转收入类科目
将所有收入类科目余额转入"本年利润"贷方：
- 借：主营业务收入
- 借：其他业务收入
- 借：营业外收入
- 　　贷：本年利润

### 第二步：结转费用类科目
将所有费用类科目余额转入"本年利润"借方：
- 借：本年利润
- 　　贷：主营业务成本
- 　　贷：其他业务成本
- 　　贷：税金及附加
- 　　贷：销售费用
- 　　贷：管理费用
- 　　贷：财务费用
- 　　贷：营业外支出
- 　　贷：所得税费用

### 第三步：结转本年利润
- 盈利时：借：本年利润 贷：利润分配-未分配利润
- 亏损时：借：利润分配-未分配利润 贷：本年利润

### 第四步：提取盈余公积
- 借：利润分配-提取盈余公积
- 　　贷：盈余公积''',
    contentEn: '''## Period-End Closing Steps

### Step 1: Close Revenue Accounts
Transfer all revenue account balances to "Current Year Profit" (credit):
- Dr: Main Operating Revenue
- Dr: Other Operating Revenue
- Dr: Non-operating Income
- 　　　Cr: Current Year Profit

### Step 2: Close Expense Accounts
Transfer all expense account balances to "Current Year Profit" (debit):
- Dr: Current Year Profit
- 　　　Cr: Main Operating Cost
- 　　　Cr: Other Operating Cost
- 　　　Cr: Taxes & Surcharges
- 　　　Cr: Selling Expenses
- 　　　Cr: Admin. Expenses
- 　　　Cr: Financial Expenses
- 　　　Cr: Non-operating Expenses
- 　　　Cr: Income Tax Expense

### Step 3: Close Current Year Profit
- If profit: Dr: Current Year Profit Cr: Profit Distribution
- If loss: Dr: Profit Distribution Cr: Current Year Profit

### Step 4: Transfer to Surplus Reserve
- Dr: Profit Distribution - Transfer to Surplus Reserve
- 　　　Cr: Surplus Reserve''',
    contentKo: '''## 기말 결산 절차

### 1단계: 수익 계정 마감
모든 수익 계정 잔액을 "당기순이익"(대변)으로 이전:
- 차: 주된영업수익
- 차: 기타영업수익
- 차: 영업외수익
- 　　　대: 당기순이익

### 2단계: 비용 계정 마감
모든 비용 계정 잔액을 "당기순이익"(차변)으로 이전:
- 차: 당기순이익
- 　　　대: 주된영업원가
- 　　　대: 기타영업원가
- 　　　대: 세금및부가세
- 　　　대: 판매비
- 　　　대: 관리비
- 　　　대: 재무비용
- 　　　대: 영업외비용
- 　　　대: 소득세비용

### 3단계: 당기순이익 마감
- 이익 시: 차: 당기순이익 대: 이익처분
- 손실 시: 차: 이익처분 대: 당기순이익

### 4단계: 이익잉여금 적립
- 차: 이익처분-이익잉여금적립
- 　　　대: 이익잉여금''',
  ),
  KnowledgeCard(
    id: 'k7', category: 'accounting_practice', relatedAccountId: '1602',
    titleZh: '固定资产折旧', titleEn: 'Fixed Asset Depreciation', titleKo: '고정자산 감가상각',
    contentZh: '''## 固定资产折旧

### 折旧方法
1. **年限平均法（直线法）**：年折旧额 = (原值 - 残值) / 使用年限
2. **工作量法**：按实际工作量计提
3. **双倍余额递减法**：加速折旧方法
4. **年数总和法**：加速折旧方法

### 会计分录
- 借：管理费用（或制造费用等）
- 　　贷：累计折旧

### 注意
- 当月增加的固定资产，当月不计提折旧，下月起计提
- 当月减少的固定资产，当月仍计提折旧，下月起停止
- 累计折旧是固定资产的备抵科目，固定资产账面价值 = 原值 - 累计折旧''',
    contentEn: '''## Fixed Asset Depreciation

### Depreciation Methods
1. **Straight-line method**: Annual depreciation = (Cost - Residual) / Useful life
2. **Units of production method**: Based on actual usage
3. **Double-declining balance**: Accelerated method
4. **Sum-of-years-digits**: Accelerated method

### Journal Entry
- Dr: Admin. Expenses (or Manufacturing Overhead)
- 　　　Cr: Accumulated Depreciation

### Notes
- Assets added this month: depreciation starts next month
- Assets disposed this month: depreciation this month, stops next month
- Accumulated depreciation is a contra-asset; book value = Cost - Accumulated depreciation''',
    contentKo: '''## 고정자산 감가상각

### 감가상각 방법
1. **정액법**: 연간 감가상각액 = (취득원가 - 잔존가치) / 내용연수
2. **생산량비례법**: 실제 사용량 기준
3. **이중체감잔액법**: 가속상각 방법
4. **연수합계법**: 가속상각 방법

### 분개
- 차: 관리비 (또는 제조간접비)
- 　　　대: 감가상각누계액

### 참고
- 당월 취득 자산: 당월 상각 없음, 익월부터 상각
- 당월 처분 자산: 당월 상각 있음, 익월부터 중지
- 감가상각누계액은 자산 차감 계정, 장부가치 = 취득원가 - 감가상각누계액''',
  ),
  KnowledgeCard(
    id: 'k8', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '试算平衡原理', titleEn: 'Trial Balance Principle', titleKo: '시산표 원리',
    contentZh: '''## 试算平衡原理

### 试算平衡表的作用
验证所有账户的借方总额是否等于贷方总额。

### 平衡依据
1. **发生额平衡**：全部账户本期借方发生额合计 = 全部账户本期贷方发生额合计
2. **余额平衡**：全部账户借方期末余额合计 = 全部账户贷方期末余额合计

### 不平衡的原因
- 记账方向错误（把借方记入贷方）
- 金额记录错误（数字不一致）
- 遗漏记账（只记了一方）
- 计算错误（汇总时计算不准）

### 注意事项
试算平衡不代表完全正确！以下情况试算仍然平衡：
- 借贷双方同时漏记或重记
- 借贷双方同时记错科目
- 借贷方向颠倒但金额相等''',
    contentEn: '''## Trial Balance Principle

### Purpose
Verify that total debits equal total credits across all accounts.

### Balance Basis
1. **Transaction balance**: Total debit entries = Total credit entries for the period
2. **Balance check**: Total debit ending balances = Total credit ending balances

### Causes of Imbalance
- Wrong direction (debit recorded as credit)
- Amount error (numbers don't match)
- Missing entry (only one side recorded)
- Calculation error (summation mistakes)

### Note
A balanced trial balance does NOT guarantee correctness! The following don't affect balance:
- Both sides omitted or duplicated equally
- Both sides posted to wrong accounts
- Debit/credit reversed but amounts equal''',
    contentKo: '''## 시산표 원리

### 목적
모든 계정의 차변 총액이 대변 총액과 일치하는지 확인합니다.

### 균형 기준
1. **발생액 균형**: 전 계정 차변 발생액 합계 = 전 계정 대변 발생액 합계
2. **잔액 균형**: 전 계정 차변 기말잔액 합계 = 전 계정 대변 기말잔액 합계

### 불균형 원인
- 방향 오류 (차변을 대변으로 기록)
- 금액 오류 (숫자 불일치)
- 누락 (한쪽만 기록)
- 계산 오류 (합산 실수)

### 주의
시산표 균형이 완전한 정확성을 보장하지 않습니다! 다음은 균형에 영향 없음:
- 양쪽 동시 누락 또는 중복
- 양쪽 모두 잘못된 계정에 기장
- 차변/대변 반전되었으나 금액 동일''',
  ),
  KnowledgeCard(
    id: 'k9', category: 'economic_law', relatedAccountId: null,
    titleZh: '会计档案保管期限', titleEn: 'Accounting Archive Retention', titleKo: '회계 기록 보존 기간',
    contentZh: '''## 会计档案保管期限

### 永久保管
- 年度财务报告（决算）
- 会计档案保管清册
- 会计档案销毁清册
- 会计档案鉴定意见书

### 保管 30 年
- 会计凭证（原始凭证、记账凭证）
- 会计账簿（总账、明细账、日记账）
- 会计档案移交清册

### 保管 10 年
- 月度、季度、半年度财务报告
- 银行存款余额调节表
- 银行对账单
- 纳税申报表

### 法律责任
故意销毁依法应当保存的会计凭证、会计账簿、财务会计报告，构成犯罪的，依法追究刑事责任。''',
    contentEn: '''## Accounting Archive Retention

### Permanent Retention
- Annual financial reports (final accounts)
- Accounting archive retention register
- Accounting archive destruction register
- Accounting archive appraisal report

### 30-Year Retention
- Accounting vouchers (source documents, journal vouchers)
- Accounting books (general ledger, detail ledgers, journals)
- Accounting archive transfer register

### 10-Year Retention
- Monthly, quarterly, semi-annual financial reports
- Bank reconciliation statements
- Bank statements
- Tax returns

### Legal Liability
Intentional destruction of accounting documents, books, or reports required by law constitutes a criminal offense. Serious cases may lead to criminal prosecution.''',
    contentKo: '''## 회계 기록 보존 기간

### 영구 보존
- 연간 재무 보고서 (결산)
- 회계 기록 보존 대장
- 회계 기록 폐기 대장
- 회계 기록 평가 의견서

### 30년 보존
- 회계 전표 (원시 증빙, 분개 전표)
- 회계 장부 (총계정원장, 보조원장, 일기장)
- 회계 기록 이관 대장

### 10년 보존
- 월간, 분기, 반기 재무 보고서
- 은행 계좌 잔액 조정표
- 은행 거래 내역서
- 세금 신고서

### 법적 책임
법적으로 보존해야 하는 회계 문서, 장부, 보고서를 고의로 폐기하는 경우 범죄가 성립되며, 중대한 경우 형사 책임을 질 수 있습니다.''',
  ),
  KnowledgeCard(
    id: 'k10', category: 'accounting_practice', relatedAccountId: null,
    titleZh: '财务报表之间的关系', titleEn: 'Relationship Between Financial Statements', titleKo: '재무제표 간의 관계',
    contentZh: '''## 财务报表之间的关系

### 三大报表
1. **资产负债表**：反映某一时点的财务状况（资产 = 负债 + 所有者权益）
2. **利润表**：反映一定期间的经营成果（收入 - 费用 = 利润）
3. **现金流量表**：反映现金及现金等价物的流入和流出

### 报表间的勾稽关系
- 利润表的**净利润** 转入 资产负债表的**未分配利润**
- 资产负债表中**现金期初与期末余额**的差额 = 现金流量表的**现金净增加额**
- 所有者权益变动表的**期末余额** = 资产负债表的**所有者权益期末余额**

### 分析路径
1. 先看利润表 → 了解盈利能力
2. 再看资产负债表 → 了解财务结构和偿债能力
3. 最后看现金流量表 → 了解现金来源和去向''',
    contentEn: '''## Relationship Between Financial Statements

### Three Main Statements
1. **Balance Sheet**: Financial position at a point in time (Assets = Liabilities + Equity)
2. **Income Statement**: Operating performance over a period (Revenue - Expenses = Profit)
3. **Cash Flow Statement**: Inflows and outflows of cash and equivalents

### Articulation Between Statements
- Income statement **net profit** flows to balance sheet **retained earnings**
- Balance sheet **cash difference (ending - beginning)** = Cash flow statement **net cash increase**
- Statement of changes in equity **ending balance** = Balance sheet **equity ending balance**

### Analysis Path
1. Start with income statement → Understand profitability
2. Then balance sheet → Understand financial structure and solvency
3. Finally cash flow statement → Understand cash sources and uses''',
    contentKo: '''## 재무제표 간의 관계

### 3대 재무제표
1. **대차대조표**: 특정 시점의 재무 상태 (자산 = 부채 + 자본)
2. **손익계산서**: 일정 기간의 경영 성과 (수익 - 비용 = 이익)
3. **현금흐름표**: 현금 및 현금성 자산의 유입과 유출

### 재무제표 간 연계
- 손익계산서의 **순이익** → 대차대조표의 **이익잉여금**
- 대차대조표 **현금 차이(기말-기초)** = 현금흐름표 **순현금증가**
- 자본변동표의 **기말잔액** = 대차대조표의 **자본 기말잔액**

### 분석 경로
1. 손익계산서 먼저 → 수익성 파악
2. 그 다음 대차대조표 → 재무 구조와 지급 능력 파악
3. 마지막 현금흐름표 → 현금 출처와 사용 파악''',
  ),
  // ==================== 税务知识 Tax Knowledge ====================
  KnowledgeCard(
    id: 't1', category: 'tax', relatedAccountId: '2221',
    titleZh: '增值税详解', titleEn: 'VAT in Detail', titleKo: '부가가치세 상세',
    contentZh: '''## 增值税详解

增值税是中国的第一大税种，对商品和服务在流转过程中产生的增值额征税。

### 纳税人
- **一般纳税人**：年应征增值税销售额 > 500万元，可抵扣进项税额
- **小规模纳税人**：年销售额 ≤ 500万元，适用简易计税

### 税率结构
| 税率 | 适用范围 |
|------|---------|
| 13% | 销售货物、加工修理修配劳务、有形动产租赁 |
| 9% | 农产品、水电气、图书、不动产、交通运输 |
| 6% | 现代服务业、金融服务、生活服务 |
| 0% | 出口货物 |

### 计算公式
**一般计税**：应纳税额 = 销项税额 - 进项税额
**简易计税**：应纳税额 = 销售额 × 征收率（3%或5%）

### 发票类型
- **增值税专用发票**：可抵扣进项税额
- **增值税普通发票**：不可抵扣
- **电子发票**：与纸质发票同等法律效力''',
    contentEn: '''## VAT in Detail

VAT is the largest tax category in China, levied on the value added during the circulation of goods and services.

### Taxpayers
- **General taxpayers**: Annual taxable sales > 5 million CNY, can deduct input VAT
- **Small-scale taxpayers**: Annual sales ≤ 5 million CNY, simplified method

### Tax Rate Structure
| Rate | Scope |
|------|-------|
| 13% | Goods sales, processing, repair, tangible movable property leasing |
| 9% | Agricultural products, utilities, books, real estate, transportation |
| 6% | Modern services, financial services, lifestyle services |
| 0% | Export goods |

### Calculation
**General**: Tax payable = Output VAT - Input VAT
**Simplified**: Tax payable = Sales × Levy rate (3% or 5%)

### Invoice Types
- **Special VAT Invoice**: Can be used for input VAT deduction
- **General VAT Invoice**: Cannot be deducted
- **E-Invoice**: Same legal effect as paper invoices''',
    contentKo: '''## 부가가치세 상세

부가가치세는 중국 최대 세목으로, 상품과 서비스 유통 과정에서 발생하는 부가가치에 부과됩니다.

### 납세자
- **일반 납세자**: 연간 과세 매출 > 500만 위안, 매입세액 공제 가능
- **간이 과세자**: 연간 매출 ≤ 500만 위안, 간이 과세 방법

### 세율 구조
| 세율 | 적용 범위 |
|------|---------|
| 13% | 상품 판매, 가공 수리 서비스, 유형 동산 임대 |
| 9% | 농산물, 공공요금, 도서, 부동산, 운송 |
| 6% | 현대 서비스, 금융 서비스, 생활 서비스 |
| 0% | 수출 상품 |

### 계산 공식
**일반 과세**: 납부세액 = 매출세액 - 매입세액
**간이 과세**: 납부세액 = 매출액 × 징수율 (3% 또는 5%)

### 세금계산서 유형
- **전용 세금계산서**: 매입세액 공제 가능
- **일반 세금계산서**: 공제 불가
- **전자 세금계산서**: 종이 세금계산서와 동일한 법적 효력''',
    relatedSubjectZh: '增值税纳税申报',
    relatedSubjectEn: 'VAT Declaration',
    relatedSubjectKo: '부가가치세 신고',
  ),
  KnowledgeCard(
    id: 't2', category: 'tax', relatedAccountId: '2221',
    titleZh: '企业所得税基础', titleEn: 'Corporate Income Tax Basics', titleKo: '법인세 기초',
    contentZh: '''## 企业所得税

企业所得税是对企业和其他取得收入的组织征收的一种税。

### 纳税人
- **居民企业**：依法在中国境内成立，或实际管理机构在中国境内的企业
- **非居民企业**：未在中国境内设立机构场所，或设立了但与所得无实际联系

### 税率
| 类型 | 税率 |
|------|------|
| 一般企业 | 25% |
| 高新技术企业 | 15% |
| 小型微利企业 | 20%（减按计算）|
| 西部大开发鼓励类企业 | 15% |

### 应纳税所得额计算
**应纳税所得额 = 收入总额 - 不征税收入 - 免税收入 - 各项扣除 - 以前年度亏损**

### 常见扣除项目
- 合理的工资薪金支出
- 职工福利费（工资总额 14% 以内）
- 工会经费（工资总额 2%）
- 职工教育经费（工资总额 8% 以内）
- 业务招待费（发生额 60%，不超过收入 5‰）
- 广告费和业务宣传费（收入 15% 以内）''',
    contentEn: '''## Corporate Income Tax

CIT is a tax levied on enterprises and other organizations that obtain income.

### Taxpayers
- **Resident enterprises**: Established in China or with effective management in China
- **Non-resident enterprises**: No establishment in China or income not connected to establishment

### Tax Rates
| Type | Rate |
|---|---|
| General enterprises | 25% |
| High-tech enterprises | 15% |
| Small low-profit enterprises | 20% (reduced basis) |
| Western development encouraged | 15% |

### Taxable Income Calculation
**Taxable income = Gross income - Non-taxable income - Tax-exempt income - Deductions - Prior year losses**

### Common Deductions
- Reasonable salary expenses
- Employee welfare (within 14% of total wages)
- Trade union fees (2% of total wages)
- Employee education (within 8% of total wages)
- Business entertainment (60% of incurred, ≤ 5‰ of revenue)
- Advertising & promotion (within 15% of revenue)''',
    contentKo: '''## 법인세

법인세는 기업 및 기타 소득을 얻는 조직에 부과되는 세금입니다.

### 납세자
- **거주 기업**: 중국 내 설립 또는 실질적 관리 기관이 중국 내 있는 기업
- **비거주 기업**: 중국 내 사업장 없거나 소득과 실질적 관련 없는 기업

### 세율
| 유형 | 세율 |
|---|---|
| 일반 기업 | 25% |
| 첨단 기술 기업 | 15% |
| 소형 저이익 기업 | 20% (할인 계산) |
| 서부 개발 장려 기업 | 15% |

### 과세 소득 계산
**과세 소득 = 총수입 - 비과세 소득 - 면세 소득 - 각종 공제 - 이전 연도 결손**

### 일반 공제 항목
- 합리적 급여 지출
- 직원 복지비 (임금 총액 14% 이내)
- 노동 조합비 (임금 총액 2%)
- 직원 교육비 (임금 총액 8% 이내)
- 접대비 (발생액 60%, 수익 5‰ 이내)
- 광고 및 판촉비 (수익 15% 이내)''',
    relatedSubjectZh: '企业所得税年度汇算清缴',
    relatedSubjectEn: 'Annual CIT Reconciliation',
    relatedSubjectKo: '연간 법인세 정산',
  ),
  KnowledgeCard(
    id: 't3', category: 'tax',
    titleZh: '发票管理与合规', titleEn: 'Invoice Management & Compliance', titleKo: '세금계산서 관리와 규정 준수',
    contentZh: '''## 发票管理

发票是企业经济活动中最重要的原始凭证之一，也是税务机关征收税款的重要依据。

### 发票的种类
1. **增值税专用发票** — 一般纳税人开具，购买方可抵扣进项税额
2. **增值税普通发票** — 不可用于抵扣
3. **机动车销售统一发票** — 购买机动车专用
4. **定额发票** — 小额交易使用
5. **电子发票** — 与纸质发票同等效力

### 发票开具要求
- 必须按实际交易内容如实开具
- 发票信息必须完整（抬头、税号、商品名称、金额、税率等）
- 不得虚开发票（与实际经营业务不符）
- 不得转借、转让发票

### 法律责任
- **虚开发票**：情节严重的，处 2 年以上 7 年以下有期徒刑
- **非法出售发票**：情节严重的，处 2 年以上 7 年以下有期徒刑
- 企业被列入税收违法"黑名单"将影响信用评级、贷款、招投标等

### 发票保管
- 已开具的发票存根联和发票登记簿应保存 5 年
- 保存期满后报经税务机关查验后方可销毁''',
    contentEn: '''## Invoice Management

Invoices are one of the most important source documents in business activities and a key basis for tax authorities to collect taxes.

### Invoice Types
1. **Special VAT Invoice** — For general taxpayers, buyer can deduct input VAT
2. **General VAT Invoice** — Cannot be used for deduction
3. **Motor Vehicle Sales Invoice** — For vehicle purchases
4. **Fixed-Amount Invoice** — For small transactions
5. **E-Invoice** — Same legal effect as paper invoices

### Issuance Requirements
- Must be issued according to actual transaction content
- Invoice information must be complete (title, tax ID, product name, amount, tax rate, etc.)
- No false invoicing (does not match actual business)
- No lending or transferring of invoices

### Legal Liability
- **False invoicing**: Aggravated cases, 2-7 years imprisonment
- **Illegal sale of invoices**: Aggravated cases, 2-7 years imprisonment
- Enterprises on tax violation "blacklist" face credit rating, loan, and bidding restrictions

### Invoice Retention
- Issued invoice stubs and registers must be kept for 5 years
- May only be destroyed after inspection by tax authorities''',
    contentKo: '''## 세금계산서 관리

세금계산서는 기업 경제 활동에서 가장 중요한 원시 증빙 중 하나이며, 세무 당국의 세금 징수를 위한 중요한 근거입니다.

### 세금계산서 유형
1. **전용 세금계산서** — 일반 납세자 발행, 구매자 매입세액 공제 가능
2. **일반 세금계산서** — 공제 불가
3. **자동차 판매 통일 세금계산서** — 자동차 구매 전용
4. **정액 세금계산서** — 소액 거래용
5. **전자 세금계산서** — 종이와 동일한 법적 효력

### 발행 요건
- 실제 거래 내용에 따라 진실하게 발행
- 세금계산서 정보 완전 (상호, 세번, 상품명, 금액, 세율 등)
- 허위 발행 금지 (실제 영업과 불일치)
- 대여, 양도 금지

### 법적 책임
- **허위 발행**: 중대한 경우 2-7년 징역
- **불법 매매**: 중대한 경우 2-7년 징역
- 세금 위반 "블랙리스트" 등재 시 신용 등급, 대출, 입찰에 영향

### 보존
- 발행된 세금계산서 보관본과 등록부는 5년간 보존
- 보존 기간 만료 후 세무 당국 검사 후 폐기 가능''',
  ),
  KnowledgeCard(
    id: 't4', category: 'tax',
    titleZh: '纳税申报流程', titleEn: 'Tax Declaration Process', titleKo: '세금 신고 절차',
    contentZh: '''## 纳税申报流程

### 申报期限

| 税种 | 申报期限 |
|------|---------|
| 增值税 | 次月 15 日前（一般纳税人按月申报）|
| 企业所得税（季报）| 季度结束后 15 日内 |
| 企业所得税（年报）| 年度结束后 5 个月内（汇算清缴）|
| 个人所得税 | 次月 15 日前 |
| 印花税 | 次月 15 日前 |
| 附加税费 | 随增值税同时申报 |

### 申报方式
1. **网上申报** — 通过电子税务局在线申报（最常用）
2. **上门申报** — 到主管税务机关办税服务厅申报
3. **邮寄申报** — 通过邮政寄送申报表

### 申报前准备
1. 核对当月所有发票（进项/销项）
2. 确认进项税额抵扣凭证
3. 计算应纳税额
4. 填写申报表
5. 核对数据无误后提交

### 逾期申报后果
- 每日加收滞纳税款万分之五的滞纳金
- 可处以 2000 元以下的罚款
- 情节严重的，处 2000 元以上 10000 元以下罚款''',
    contentEn: '''## Tax Declaration Process

### Filing Deadlines

| Tax Type | Deadline |
|----------|----------|
| VAT | 15th of following month (monthly for general taxpayers) |
| CIT (quarterly) | Within 15 days after quarter end |
| CIT (annual) | Within 5 months after year end (reconciliation) |
| Individual Income Tax | 15th of following month |
| Stamp Duty | 15th of following month |
| Surcharges | Filed with VAT simultaneously |

### Filing Methods
1. **Online filing** — Via e-Tax Bureau (most common)
2. **In-person filing** — At tax service hall
3. **Mail filing** — Submit returns by post

### Pre-Filing Preparation
1. Verify all monthly invoices (input/output)
2. Confirm input VAT deduction documents
3. Calculate tax payable
4. Complete tax return forms
5. Verify data and submit

### Late Filing Consequences
- Daily surcharge of 0.05% of unpaid tax
- Fine of up to 2,000 CNY
- Aggravated cases: fine of 2,000-10,000 CNY''',
    contentKo: '''## 세금 신고 절차

### 신고 기한

| 세목 | 신고 기한 |
|------|---------|
| 부가가치세 | 익월 15일까지 (일반 납세자는 월별 신고) |
| 법인세 (분기) | 분기 종료 후 15일 이내 |
| 법인세 (연간) | 연도 종료 후 5개월 이내 (정산) |
| 개인소득세 | 익월 15일까지 |
| 인지세 | 익월 15일까지 |
| 부가세 | 부가가치세와 동시 신고 |

### 신고 방법
1. **온라인 신고** — 전자 세무국을 통한 온라인 신고 (가장 일반적)
2. **방문 신고** — 관할 세무서 방문 신고
3. **우편 신고** — 우편으로 신고서 제출

### 신고 전 준비
1. 당월 모든 세금계산서 확인 (매입/매출)
2. 매입세액 공제 증빙 확인
3. 납부세액 계산
4. 신고서 작성
5. 데이터 확인 후 제출

### 기한 초과 신고 결과
- 미납 세금의 일 0.05% 가산금
- 최대 2,000위안 벌금
- 중대한 경우: 2,000-10,000위안 벌금''',
  ),
  KnowledgeCard(
    id: 't5', category: 'tax',
    titleZh: '个人所得税常识', titleEn: 'Individual Income Tax Basics', titleKo: '개인소득세 기본',
    contentZh: '''## 个人所得税

### 征税范围
- 工资、薪金所得
- 劳务报酬所得
- 稿酬所得
- 特许权使用费所得
- 经营所得
- 利息、股息、红利所得
- 财产租赁/转让所得
- 偶然所得

### 综合所得税率（工资薪金等）
| 级数 | 全年应纳税所得额 | 税率 | 速算扣除数 |
|------|----------------|------|-----------|
| 1 | ≤ 36,000 | 3% | 0 |
| 2 | 36,000 ~ 144,000 | 10% | 2,520 |
| 3 | 144,000 ~ 300,000 | 20% | 16,920 |
| 4 | 300,000 ~ 420,000 | 25% | 31,920 |
| 5 | 420,000 ~ 660,000 | 30% | 52,920 |
| 6 | 660,000 ~ 960,000 | 35% | 85,920 |
| 7 | > 960,000 | 45% | 181,920 |

### 专项附加扣除
- 子女教育：每个子女每月 2,000 元
- 继续教育：每月 400 元
- 大病医疗：年度限额 80,000 元
- 住房贷款利息：每月 1,000 元
- 住房租金：每月 800-1,500 元
- 赡养老人：每月 2,000-3,000 元
- 3岁以下婴幼儿照护：每名每月 2,000 元''',
    contentEn: '''## Individual Income Tax

### Taxable Scope
- Wages and salaries
- Labor remuneration
- Author's remuneration
- Royalties
- Business income
- Interest, dividends, bonuses
- Property rental/transfer income
- Incidental income

### Comprehensive Income Tax Rates
| Level | Annual Taxable Income | Rate | Quick Deduction |
|-------|---------------------|------|-----------------|
| 1 | ≤ 36,000 | 3% | 0 |
| 2 | 36,000 ~ 144,000 | 10% | 2,520 |
| 3 | 144,000 ~ 300,000 | 20% | 16,920 |
| 4 | 300,000 ~ 420,000 | 25% | 31,920 |
| 5 | 420,000 ~ 660,000 | 30% | 52,920 |
| 6 | 660,000 ~ 960,000 | 35% | 85,920 |
| 7 | > 960,000 | 45% | 181,920 |

### Special Additional Deductions
- Children's education: 2,000 CNY/month per child
- Continuing education: 400 CNY/month
- Serious illness medical: 80,000 CNY/year cap
- Housing loan interest: 1,000 CNY/month
- Housing rent: 800-1,500 CNY/month
- Elderly support: 2,000-3,000 CNY/month
- Infant care (under 3): 2,000 CNY/month per child''',
    contentKo: '''## 개인소득세

### 과세 범위
- 급여, 임금 소득
- 노무 보수 소득
- 저작권료 소득
- 로열티 소득
- 사업 소득
- 이자, 배당, 보너스 소득
- 재산 임대/양도 소득
- 일시적 소득

### 종합 소득 세율 (급여 등)
| 등급 | 연간 과세 소득 | 세율 | 간편 공제 |
|------|-------------|------|----------|
| 1 | ≤ 36,000 | 3% | 0 |
| 2 | 36,000 ~ 144,000 | 10% | 2,520 |
| 3 | 144,000 ~ 300,000 | 20% | 16,920 |
| 4 | 300,000 ~ 420,000 | 25% | 31,920 |
| 5 | 420,000 ~ 660,000 | 30% | 52,920 |
| 6 | 660,000 ~ 960,000 | 35% | 85,920 |
| 7 | > 960,000 | 45% | 181,920 |

### 특별 부가 공제
- 자녀 교육: 자녀당 월 2,000위안
- 계속 교육: 월 400위안
- 중대 질병 의료: 연간 80,000위안 한도
- 주택 대출 이자: 월 1,000위안
- 주택 임대료: 월 800-1,500위안
- 노인 부양: 월 2,000-3,000위안
- 영아 보육 (3세 미만): 아동당 월 2,000위안''',
  ),
];
