//
//  ViewController.m
//  SabiasQue
//
//  Implementa el planteamiento de la app "¿Sabías qué?":
//  a) El usuario selecciona una de tres categorías.
//  b) Al tocar un botón se muestra un dato curioso de esa categoría.
//  c) Al tocar de nuevo el botón se muestra un dato DIFERENTE de la misma categoría.
//

#import "ViewController.h"

@interface ViewController ()

// Vista 1: selección de categoría (pantalla 1 del wireframe)
@property (nonatomic, strong) UIView *categoryView;

// Vista 2: dato curioso (pantalla 2 del wireframe)
@property (nonatomic, strong) UIView *factView;
@property (nonatomic, strong) UILabel *categoryTitleLabel;
@property (nonatomic, strong) UILabel *factLabel;

// Datos de la app
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *facts;
@property (nonatomic, strong) NSString *selectedCategory;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *lastIndexByCategory;

@end

@implementation ViewController

#pragma mark - Ciclo de vida

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"¿Sabías qué?";

    [self setupData];
    [self buildCategoryView];
    [self buildFactView];

    // Al iniciar se muestra la pantalla de selección de categoría
    self.factView.hidden = YES;
}

#pragma mark - Datos (3 categorías con varios datos curiosos cada una)

- (void)setupData {
    self.facts = @{
        @"Ciencia": @[
            @"El corazón humano late aproximadamente 100,000 veces al día.",
            @"La luz del Sol tarda 8 minutos en llegar a la Tierra.",
            @"El cuerpo humano tiene alrededor de 37 billones de células.",
            @"El agua puede hervir y congelarse al mismo tiempo (punto triple)."
        ],
        @"Historia": @[
            @"La Gran Muralla China mide más de 21,000 km de longitud.",
            @"La Torre Eiffel fue construida en 1889 para una exposición universal.",
            @"El imperio romano duró aproximadamente 1,000 años.",
            @"La imprenta de Gutenberg se inventó alrededor de 1440."
        ],
        @"Naturaleza": @[
            @"Un pulpo tiene tres corazones y sangre azul.",
            @"Las abejas pueden reconocer rostros humanos.",
            @"El árbol más alto del mundo mide más de 115 metros.",
            @"Algunas tortugas pueden vivir más de 100 años."
        ]
    };

    self.lastIndexByCategory = [NSMutableDictionary dictionary];
}

#pragma mark - Pantalla 1: Selección de categoría

- (void)buildCategoryView {
    self.categoryView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.categoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.categoryView];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Elige una categoría";
    subtitle.font = [UIFont italicSystemFontOfSize:16];
    subtitle.textAlignment = NSTextAlignmentCenter;
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.categoryView addSubview:subtitle];

    NSArray<NSString *> *categories = @[@"Ciencia", @"Historia", @"Naturaleza"];
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    stack.distribution = UIStackViewDistributionFillEqually;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.categoryView addSubview:stack];

    for (NSString *category in categories) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:category forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        button.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        button.layer.cornerRadius = 12;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blackColor].CGColor;
        [button.heightAnchor constraintEqualToConstant:70].active = YES;
        [button addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [stack addArrangedSubview:button];
    }

    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"Toca una categoría para continuar";
    hint.font = [UIFont systemFontOfSize:12];
    hint.textColor = [UIColor grayColor];
    hint.textAlignment = NSTextAlignmentCenter;
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    [self.categoryView addSubview:hint];

    UILayoutGuide *safe = self.categoryView.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [subtitle.topAnchor constraintEqualToAnchor:safe.topAnchor constant:24],
        [subtitle.centerXAnchor constraintEqualToAnchor:self.categoryView.centerXAnchor],

        [stack.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:40],
        [stack.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [stack.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],

        [hint.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor constant:-24],
        [hint.centerXAnchor constraintEqualToAnchor:self.categoryView.centerXAnchor],
    ]];
}

- (void)categoryButtonTapped:(UIButton *)sender {
    self.selectedCategory = [sender titleForState:UIControlStateNormal];
    self.categoryTitleLabel.text = self.selectedCategory;
    [self.lastIndexByCategory removeObjectForKey:self.selectedCategory];

    [self showNextFact];       // muestra el primer dato al entrar
    self.categoryView.hidden = YES;
    self.factView.hidden = NO;
}

#pragma mark - Pantalla 2: Dato curioso

- (void)buildFactView {
    self.factView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.factView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.factView];

    self.categoryTitleLabel = [[UILabel alloc] init];
    self.categoryTitleLabel.font = [UIFont boldSystemFontOfSize:22];
    self.categoryTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.factView addSubview:self.categoryTitleLabel];

    UIView *box = [[UIView alloc] init];
    box.layer.borderWidth = 1.5;
    box.layer.borderColor = [UIColor blackColor].CGColor;
    box.layer.cornerRadius = 8;
    box.translatesAutoresizingMaskIntoConstraints = NO;
    [self.factView addSubview:box];

    self.factLabel = [[UILabel alloc] init];
    self.factLabel.numberOfLines = 0;
    self.factLabel.font = [UIFont systemFontOfSize:18];
    self.factLabel.textAlignment = NSTextAlignmentCenter;
    self.factLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [box addSubview:self.factLabel];

    UIButton *showButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [showButton setTitle:@"Muéstrame otro dato" forState:UIControlStateNormal];
    showButton.titleLabel.font = [UIFont systemFontOfSize:18];
    showButton.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    showButton.layer.cornerRadius = 10;
    showButton.layer.borderWidth = 1;
    showButton.layer.borderColor = [UIColor blackColor].CGColor;
    showButton.translatesAutoresizingMaskIntoConstraints = NO;
    [showButton addTarget:self action:@selector(showNextFact) forControlEvents:UIControlEventTouchUpInside];
    [self.factView addSubview:showButton];

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"< Regresar a categorías" forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:15];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.factView addSubview:backButton];

    UILayoutGuide *safe = self.factView.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.categoryTitleLabel.topAnchor constraintEqualToAnchor:safe.topAnchor constant:24],
        [self.categoryTitleLabel.centerXAnchor constraintEqualToAnchor:self.factView.centerXAnchor],

        [box.topAnchor constraintEqualToAnchor:self.categoryTitleLabel.bottomAnchor constant:32],
        [box.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [box.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [box.heightAnchor constraintGreaterThanOrEqualToConstant:180],

        [self.factLabel.topAnchor constraintEqualToAnchor:box.topAnchor constant:16],
        [self.factLabel.bottomAnchor constraintEqualToAnchor:box.bottomAnchor constant:-16],
        [self.factLabel.leadingAnchor constraintEqualToAnchor:box.leadingAnchor constant:16],
        [self.factLabel.trailingAnchor constraintEqualToAnchor:box.trailingAnchor constant:-16],

        [showButton.topAnchor constraintEqualToAnchor:box.bottomAnchor constant:32],
        [showButton.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:24],
        [showButton.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-24],
        [showButton.heightAnchor constraintEqualToConstant:54],

        [backButton.topAnchor constraintEqualToAnchor:showButton.bottomAnchor constant:16],
        [backButton.centerXAnchor constraintEqualToAnchor:self.factView.centerXAnchor],
    ]];
}

// b) y c): al tocar el botón se muestra un dato; al tocarlo de nuevo, uno diferente.
- (void)showNextFact {
    NSArray<NSString *> *factsForCategory = self.facts[self.selectedCategory];
    if (factsForCategory.count == 0) {
        self.factLabel.text = @"No hay datos disponibles.";
        return;
    }

    NSInteger lastIndex = [self.lastIndexByCategory[self.selectedCategory] integerValue];
    NSInteger nextIndex = lastIndex;

    if (factsForCategory.count > 1) {
        // Se garantiza que el siguiente índice sea distinto al anterior.
        while (nextIndex == lastIndex) {
            nextIndex = arc4random_uniform((uint32_t)factsForCategory.count);
        }
    }

    self.lastIndexByCategory[self.selectedCategory] = @(nextIndex);
    self.factLabel.text = factsForCategory[nextIndex];
}

- (void)backButtonTapped {
    self.factView.hidden = YES;
    self.categoryView.hidden = NO;
}

@end
