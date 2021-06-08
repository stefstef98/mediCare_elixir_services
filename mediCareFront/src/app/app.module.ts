import {NgModule} from '@angular/core';
import {BrowserModule} from '@angular/platform-browser';

import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';
import {LoginComponent} from './main/login/login.component';
import {RegisterComponent} from './main/register/register.component';
import {FormsModule, ReactiveFormsModule} from "@angular/forms";
import {NavigateMenuComponent} from './main/navigate-menu/navigate-menu.component';
import {DashboardComponent} from './main/dashboard/dashboard.component';
import {SymptomViewComponent} from './main/views/symptom/symptom-view/symptom-view.component';
import {SymptomCreateComponent} from './main/views/symptom/symptom-create/symptom-create.component';
import {RouterModule} from "@angular/router";
import {HTTP_INTERCEPTORS, HttpClientModule} from "@angular/common/http";
import {BrowserAnimationsModule} from "@angular/platform-browser/animations";
import {ExtendedModule, FlexModule} from "@angular/flex-layout";
import {InterceptorService} from "./interceptors/interceptor.service";

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    RegisterComponent,
    NavigateMenuComponent,
    DashboardComponent,
    SymptomViewComponent,
    SymptomCreateComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    RouterModule,
    FormsModule,
    HttpClientModule,
    BrowserAnimationsModule,
    ReactiveFormsModule,
    FlexModule,
    ExtendedModule,
  ],
  providers: [{
    provide: HTTP_INTERCEPTORS, useClass: InterceptorService, multi: true
  }],
  bootstrap: [AppComponent]
})
export class AppModule {
}
