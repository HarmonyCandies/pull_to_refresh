@Entry
@Component
struct HomePage {
  // @Provide('a') test: string = 'abc';

  @Builder
  builder2($$: { a: string }) {
    Text(`${$$.a}测试`)
  }

  // @Builder
  // builder1() {
  //   CustomWidgetChild({ builder: this.builder2 })
  // }

  build() {
    Column() {
      Refresh({refreshing:true}){

      }
      CustomWidget() {
        CustomWidgetChild({ builder: this.builder2 })
      }
    }
  }
}


@Component
struct CustomWidget {
  @Provide('a') a: string='abc';
  // @Consume('a') a: string;
  @BuilderParam
  builder: () => void;

  build() {
    Column() {
      Button('你好').onClick((x) => {
        if (this.a == 'ddd') {
          this.a = 'abc';
        }
        else {
          this.a = 'ddd';
        }

      })
      this.builder()
    }
  }
}


@Component
struct CustomWidgetChild {
  @Consume('a') a: string;
  @BuilderParam
  builder: ($$: { a: string }) => void;

  build() {
    Column() {
      this.builder({ a: this.a })
    }
  }
}


