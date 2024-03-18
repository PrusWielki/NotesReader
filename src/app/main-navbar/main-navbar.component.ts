import { Component } from '@angular/core';

@Component({
  selector: 'app-main-navbar',
  standalone: true,
  imports: [],
  templateUrl: './main-navbar.component.html',
  styleUrl: './main-navbar.component.scss',
})
export class MainNavbarComponent {
  public getTheme() {
    const theme = localStorage.getItem('theme') || 'fantasy';
    console.log('theme');
    return theme === 'fantasy';
  }
}
