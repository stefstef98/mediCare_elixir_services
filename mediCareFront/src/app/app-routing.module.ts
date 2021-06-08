import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {LoginComponent} from "./main/login/login.component";
import {RegisterComponent} from "./main/register/register.component";
import {AuthGuardService} from "./main/guards/auth-guard.service";
import {DashboardComponent} from "./main/dashboard/dashboard.component";
import {SymptomCreateComponent} from "./main/views/symptom/symptom-create/symptom-create.component";
import {SymptomViewComponent} from "./main/views/symptom/symptom-view/symptom-view.component";

const routes: Routes = [
  {
    path: '',
    redirectTo: 'login',
    pathMatch: 'full'
  },
  {
    path: 'login',
    component: LoginComponent
  },
  {
    path: 'register',
    component: RegisterComponent
  },
  {
    path: 'dashboard',
    component: DashboardComponent,
    canActivate: [AuthGuardService],
    children: [
      {
        path: 'symptoms',
        component: SymptomViewComponent,
      },
      {
        path: 'symptoms/create',
        component: SymptomCreateComponent,
      },
    ]
  },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {
}
